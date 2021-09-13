# Set the account info for deployment.
server <- "shinyapps.io"
account <- Sys.getenv("SHINYAPPS_NAME", "unleash-shiny")

# Logic from `testthat::on_ci()`
if (isTRUE(as.logical(Sys.getenv("CI")))) {
  rsconnect::setAccountInfo(
    name   = account,
    token  = Sys.getenv("SHINYAPPS_TOKEN"),
    secret = Sys.getenv("SHINYAPPS_SECRET")
  )
}


deploy_app <- function(
  app_dir,
  name,
  ...
) {
  cat("\n\n\n")
  message("Deploying: ", paste0(readLines(file.path(app_dir, "app.R")), collapse = "\n"))

  rsconnect::deployApp(
    appDir = app_dir,
    appName = name,
    server = server,
    account = account,
    forceUpdate = TRUE,
    ...
  )
}



# code_chunk(OSUICode::get_example("tabler/button"), "r")
pkg_root <-  rprojroot::find_package_root_file("")
app_list <- lapply(dir(pkg_root, pattern = "\\.Rmd$"), function(rmd) {
  rmd_lines <- readLines(rmd, warn = FALSE)
  is_example_code <- grepl("OSUICode::get_example", rmd_lines, fixed = TRUE)
  if (!any(is_example_code)) return(NULL)
  example_lines <- rmd_lines[is_example_code]
  # collect app name like `"tabler/button"`
  app_names <- sub('^.*OSUICode::get_example\\("([^"]+)".*$', "\\1", example_lines)
  # collect package name used (if any) otherwise use `"OSUICode"`
  package_names <- rep("OSUICode", length(app_names))
  has_package <- grepl("package\\s*=", example_lines)
  package_names[has_package] <- sub('^.*OSUICode::get_example\\(.*package\\s*=\\s*"([^"]+)".*$', "\\1", example_lines[has_package])

  data.frame(
    app_name = app_names,
    package_name = package_names
  )
})

# Find all unique combinations of apps and packages
apps <- unique(do.call(rbind, app_list))
message("Applications:")
print(apps)

library_deps <- desc::desc(file.path(pkg_root, "DESCRIPTION"))$get_deps()
library_code <- paste0(
  "# Insert code to trick `manifest.json` creation\n",
  "if (FALSE) {",
    "\n",
    paste0("  library(", library_deps$package, ")", collapse = "\n"),
    "\n",
  "}"
)

apps$i <- seq_len(nrow(apps))

# Deploy in parallel
doParallel::registerDoParallel(cores = 3)

for (i in 1:3) {
  deploy_worked <- plyr::m_ply(
    .parallel = TRUE,
    apps,
    function(app_name, package_name, i) {
      app_dir <- file.path(tempdir(), tempfile("OSUICode-app-"))
      dir.create(app_dir, recursive = TRUE, showWarnings = FALSE)
      on.exit({
        unlink(app_dir, recursive = TRUE)
      }, add = TRUE)

      # Make app.R
      cat(
        file = file.path(app_dir, "app.R"),
        paste0(
        "# ", i, "/", nrow(apps), "\n",
        "# Copy in impossible-to-reach library calls to populate the manifest file\n",
        library_code, "\n",
        "\n",
        "OSUICode::run_example(",
          "\"", as.character(app_name), "\", ",
          "package = \"", as.character(package_name), "\"",
        ")\n")
      )

      # Deploy!
      tryCatch({
        deploy_app(
          app_dir = app_dir,
          name = gsub("/", "_", app_name, fixed = TRUE)
        )
        TRUE
      }, error = function(e) {
        message("Error deploying ", app_name, ":\n", e)
        FALSE
      })
    }
  )
  if (all(deploy_worked)) break
  # Subset apps to only those that failed and try again
  apps <- apps[!deploy_worked, , drop = FALSE]
}


message("done!")
