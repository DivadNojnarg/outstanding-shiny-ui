# Set the account info for deployment.
server <- "shinyapps.io"
account <- Sys.getenv("SHINYAPPS_NAME", "unleash-shiny")

if (isTRUE(Sys.getenv("CI"))) {
  rsconnect::setAccountInfo(
    name   = account,
    token  = Sys.getenv("SHINYAPPS_TOKEN"),
    secret = Sys.getenv("SHINYAPPS_SECRET")
  )
}


deploy_app <- function(
  app_dir,
  name,
  package,
  ...
) {
  cat("\n\n\n")
  message("Deploying: ", name, " from package: ", package, "\n")

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
for (rmd in dir(pkg_root, pattern = "\\.Rmd$")) {
  rmd_lines <- readLines(rmd, warn = FALSE)
  is_example_code <- grepl("OSUICode::get_example", rmd_lines, fixed = TRUE)
  if (any(is_example_code)) {
    example_lines <- rmd_lines[is_example_code]
    # collect app name like `"tabler/button"`
    app_names <- sub('^.*OSUICode::get_example\\("([^"]+)".*$', "\\1", example_lines)
    # collect package name used (if any) otherwise use `"OSUICode"`
    package_names <- rep("OSUICode", length(app_names))
    has_package <- grepl("package\\s*=", example_lines)
    package_names[has_package] <- sub('^.*OSUICode::get_example\\(.*package\\s*=\\s*"([^"]+)".*$', "\\1", example_lines[has_package])

    Map(
      app_name = app_names,
      package_name = package_names,
      f = function(app_name, package_name) {
        app_dir <- file.path(tempdir(), tempfile("OSUICode-app-"))
        dir.create(app_dir, recursive = TRUE, showWarnings = FALSE)
        on.exit({
          unlink(app_dir, recursive = TRUE)
        }, add = TRUE)

        # Make app.R
        cat(
          file = file.path(app_dir, "app.R"),
          "\nOSUICode::run_example(\"", app_name, "\", package = \"", package_name, "\")\n"
        )

        # Copy in DESCRIPTION to find package deps
        file.copy(
          file.path(pkg_root, "DESCRIPTION"),
          file.path(app_dir, "DESCRIPTION")
        )

        # Deploy!
        deploy_app(
          app_dir = app_dir,
          name = gsub("/", "_", app_name, fixed = TRUE),
          package = package_name
        )
      }
    )

  }
}


message("done")
