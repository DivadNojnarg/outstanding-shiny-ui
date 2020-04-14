--- 
title: "Outstanding User Interfaces with Shiny"
author: "David Granjon"
date: "2020-04-14"
site: bookdown::bookdown_site
output: bookdown::gitbook
documentclass: book
bibliography: [book.bib, packages.bib]
biblio-style: apalike
link-citations: yes
github-repo: rstudio/bookdown-demo
description: "This book will serve as content for the 2020 erum workshop."
---

# Prerequisites {-}

  - Be familiar with [Shiny](https://mastering-shiny.org)
  - Basic knowledge in HTML and JavaScript is a plus but not mandatory

## Disclaimer {-}

This book is not an HTML/Javascript/CSS course! Instead, it provides a _survival kit_ to be able to customize Shiny. I am sure however that readers will want to explore more about these topics.

## Is this book for me? {-}

You should read this book if you answer yes to the following questions:

  - Do you want to know how to develop outstanding shiny apps?
  - Have you ever wondered how to develop new input widgets?
  

## Related content {-}

See the [RStudio Cloud](https://rstudio.cloud) dedicated project.


```r
library(shiny)
library(shinydashboard)
library(shiny.semantic)
library(cascadess)
library(htmltools)
library(purrr)
library(magrittr)
```



<!--chapter:end:index.Rmd-->

# Introduction {#intro}

There are various Shiny focused resources introducing basic as well as advanced topics such as modules and Javascript/R interactions. However, handling advanced user interfaces was never an emphasis. Clients often desire custom designs, yet this generally exceeds core features of Shiny. We recognized that R App developers lacking a significant background in web development may have found this requirement to be overwhelming. Consequently, the aim of this book is to provide readers the necessary knowledge to extend Shiny's layout, input widgets and output elements. This book is organized into four parts. We first go through the basics of HTML, JavaScript and jQuery. In part 2, we dive into the {htmltools} package, providing functions to create and manipulate shiny tags as well as manage dependencies. Part 3 homes in on the development of a new template on top of Shiny by demonstrating examples from the {bs4Dash} and {shinyMobile} packages, part of the RinteRface project.

<!--chapter:end:intro.Rmd-->

# (PART\*) Survival Kit {-}

This part will give you basis in HTML, JavaScript to get started...

<!--chapter:end:survival-kit.Rmd-->

# HTML {#survival-kit-html}


<!--chapter:end:survival-kit-html.Rmd-->

# JavaScript {#survival-kit-javascript}


<!--chapter:end:survival-kit-javascript.Rmd-->

# Shiny {#survival-kit-shiny}

<!--chapter:end:survival-kit-shiny.Rmd-->

# (PART\*) htmltools {-}

While building a custom html template, you will need to know more about the wonderful [htmltools](https://github.com/rstudio/htmltools) developed by Winston Chang, member of the shiny core team. It has the same spirit as devtools, that is, making your web developer life easier. What follows does not have the pretention to be an exhaustive guide about this package. Yet, it will provide you yith the main tools to be more efficient.


<!--chapter:end:htmltools.Rmd-->

# htmltools overview {#htmltools-overview}

## HTML Tags

htmltools contains tools to write HTML tags we saw in Chapter \@ref(survival-kit-html):


```r
div()
```

If you had to gather multiple tags together, prefer `tagList()` as `list()`, although the HTML output is the same. The first has the shiny.tag.list class in addition to list. (The [Golem](http://golemverse.org) package allows to test if a R object is a tag list, therefore using list would make the test fail).

## Notations
Whether to use `tags$div` or `div` depends if the tag is exported by default.
For instance, you could use `htmltools::div` but not `htmltools::nav` since nav does not have a dedicated function (only for p, h1, h2, h3, h4, h5, h6, a, br, div, span, pre, code, img, strong, em, hr). 
Rather use `htmltools::tags$nav`. Alternatively, there exists a function (in shiny and htmltools) 
called `withTags()`. Wrapping your code in this function enables you to use `withTags(nav(), ...)` 
instead of `tags$nav()`.

## Adding new tags
The `tag` function allows to add extra HTML tags not already defined. You may use it as follows:


```r
tag("test", list(class = "test", p("Custom Tag")))
# structure below
█─tag 
├─"test" 
└─█─list 
├─class = "test" 
└─█─p 
└─"Custom Tag" 
```

## Alternative way to write tags
htmltools comes with the `HTML()` function that you can feed with raw HTML:


```r
HTML('<div>Blabla</div>')
# will render exactly like
div("Blabla")

# but there class is different
class(HTML('<div>Blabla</div>'))
class(div("Blabla"))
```

You will not be able to use tag related functions, as in the following parts.
Therefore, I strongly recommand using R and not mixing HTML in R. Interestingly, if
you want to convert HTML to R code, there is a Shiny App developed by Alan
Dipert from RStudio, namely [html2R](https://github.com/alandipert/html2r). There
are some issues, non standard attributes (like `data-toggle`) are not correctly processed but there are [fixes](https://github.com/alandipert/html2r/issues/2). This will save you precious time!

[![](outstanding-shiny-ui_files/figure-latex/unnamed-chunk-5-1.pdf)](https://alandipert.shinyapps.io/html2r/)<!-- --> 


## Playing with tags

### Tags structure

According to the `tag` function, a tag has:

- a name such as span, div, h1 ... `tag$name`
- some attributes, which you can access with `tag$attribs`
- children, which you can access with `tag$children`
- a class, namely "shiny.tag"

For instance:


```r
# create the tag
myTag <- div(
  class = "divclass", 
  id = "first",
  h1("Here comes your baby"),
  span(class = "child", id = "baby", "Crying")
)
# access its name
myTag$name
# access its attributes (id and class)
myTag$attribs
# access children (returns a list of 2 elements)
myTag$children
# access its class
class(myTag)
```

How to modify the class of the second child, namely span?


```r
second_children <- myTag$children[[2]]
second_children$attribs$class <- "adult"
myTag
# Hummm, this is not working ...
```

Why is this not working? By assigning `myTag$children[[2]]` to second_children, `second_children$attribs$class <- "adult"` modifies the class of the copy and not the original object. Thus we do:


```r
myTag$children[[2]]$attribs$class <- "adult"
myTag
```

In the following section we explore helper functions, such as `tagAppendChild` from htmltools.


### Useful functions for tags

htmltools and Shiny have powerful functions to easily add attributes to tags, check for existing attributes, get attributes and add other siblings to a list of tags.

#### Add attributes

- `tagAppendAttributes`: this function allow you to add a new attribute to the current tag.

For instance, assuming you created a div for which you forgot to add an id attribute:


```r
mydiv <- div("Where is my brain")
mydiv <- tagAppendAttributes(mydiv, id = "here_it_is")
```

You can pass as many attributes as you want, including non standard attributes such as `data-toggle` (see Bootstrap 3 tabs for instance):


```r
mydiv <- tagAppendAttributes(mydiv, `data-toggle` = "tabs")
# even though you could proceed as follows
mydiv$attribs[["aria-controls"]] <- "home"
```

#### Check if tag has specific attribute

- `tagHasAttribute`: to check if a tag has a specific attribute


```r
# I want to know if div has a class
mydiv <- div(class = "myclass")
has_class <- tagHasAttribute(mydiv, "class")
has_class
# if you are familiar with %>%
has_class <- mydiv %>% tagHasAttribute("class")
has_class
```

#### Get all attributes 

- `tagGetAttribute`: to get the value of the targeted attributes, if it exists, otherwise NULL.


```r
mydiv <- div(class = "test")
# returns the class
tagGetAttribute(mydiv, "class")
# returns NULL
tagGetAttribute(mydiv, "id")
```

#### Set child/children

- `tagSetChildren` allows to create children for a given tag. For instance:


```r
mydiv <- div(class = "parent", id = "mother", "Not the mama!!!")
# mydiv has 1 child "Not the mama!!!"
mydiv 
children <- lapply(1:3, span)
mydiv <- tagSetChildren(mydiv, children)
# mydiv has 3 children, the first one was removed
mydiv 
```

Notice that `tagSetChildren` removes all existing children. Below we see another set of functions to add children while conserving existing ones.

#### Add child or children

- `tagAppendChild` and `tagAppendChildren`: add other tags to an existing tag.
Whereas `tagAppendChild` only takes one tag, you can pass a list of tags to `tagAppendChildren`.


```r
mydiv <- div(class = "parent", id = "mother", "Not the mama!!!")
otherTag <- span("I am your child")
mydiv <- tagAppendChild(mydiv, otherTag)
```

You might wonder why there is no `tagRemoveChild` or `tagRemoveAttributes`.
Let's look at the `tagAppendChild`


```r
tagAppendChild <- function (tag, child) {
  tag$children[[length(tag$children) + 1]] <- child
  tag
}
```

Below we write the `tagRemoveChild`, where tag is the target and n is the position to remove in the list of children:


```r
mydiv <- div(class = "parent", id = "mother", "Not the mama!!!", span("Hey!"))

# we create the tagRemoveChild function
tagRemoveChild <- function(tag, n) {
  # check if the list is empty
  if (length(tag$children) == 0) {
    stop(paste(tag$name, "does not have any children!"))
  }
  tag$children[n] <- NULL
  tag
}
mydiv <- tagRemoveChild(mydiv, 1)
mydiv
```

When defining the `tagRemoveChild`, we choose `[` instead of `[[` to allow to select multiple list elements:


```r
mydiv <- div(class = "parent", id = "mother", "Not the mama!!!", "Hey!")
# fails
`[[`(mydiv$children, c(1, 2))
# works
`[`(mydiv$children, c(1, 2))
```

Alternatively, we could also create a `tagRemoveChildren` function. Also notice that the function raises an error if the provided tag does not have children. 

### Other interesting functions
The [Golem](https://github.com/ThinkR-open/golem/blob/dev/inst/utils/golem_utils_ui.R) package written by [thinkr](https://thinkr.fr) contains neat functions to edit your tags. 

Particularly, the `tagRemoveAttributes`:


```r
tagRemoveAttributes <- function(tag, ...) {
  attrs <- as.character(list(...))
  for (i in seq_along(attrs)) {
    tag$attribs[[ attrs[i] ]] <- NULL
  }
  tag
}
```


```r
mydiv <- div(class = "test", id = "coucou", "Hello")
tagRemoveAttributes(mydiv, "class", "id")
```


### Conditionally set attributes

Sometimes, you only want to set attributes under specific conditions. 


```r
my_button <- function(color = NULL) {
  tags$button( 
    style = paste("color:", color),
    p("Hello")
  )
}

my_button()
```

This example will not fail but having `style="color: "` is not clean. We may use conditions:


```r
my_button <- function(color = NULL) {
  tags$button( 
    style = if (!is.null(color)) paste("color:", color),
    p("Hello")
  )
}

my_button("blue")
my_button()
```

In this example, style won't be available if color is not specified.

### Using %>%

While doing a lot of manipulation for a tag, if you don't need to create intermediate
objects, this is a good idea to use `%>%` from magrittr:


```r
div(class = "cl", h1("Hello")) %>% 
  tagAppendAttributes(id = "myid") %>%
  tagAppendChild(p("some extra text here!"))
```

### Programmatically create children elements

Assume you want to create a tag with 3 children inside:


```r
div(
  span(1),
  span(2),
  span(3),
  span(4),
  span(5)
)
```

The structure is correct but imagine if you had to create 1000 `span` or fancier tag. The previous approach is not consistent with DRY programming. `lapply` function will be useful here (or the purrr `map` family):


```r
# base R
div(lapply(1:5, function(i) span(i)))
# purrr + %>%
map(1:5, function(i) span(i)) %>% div()
```

<!--chapter:end:htmltools-overview.Rmd-->

# Dependency utilities {#htmltools-dependencies}
When creating a new template, you sometimes need to import custom HTML dependencies
that do not come along with shiny. No problem, htmltools is here for you (shiny also 
contains these functions).


## The dirty approach
Let's consider the following example. I want to include a bootstrap 4 card in a shiny app.
This example is taken from an interesting question [here](https://community.rstudio.com/t/create-a-div-using-htmltools-withtags/22439/2).
The naive approach would be to include the HTML code directly in the app code


```r
# we create the card function before
my_card <- function(...) {
  withTags(
    div(
      class = "card border-success mb-3",
      div(class = "card-header bg-transparent border-success"),
      div(
        class = "card-body text-success",
        h3(class = "card-title", "title"),
        p(class = "card-text", ...)
      ),
      div(class = "card-footer bg-transparent border-success", "footer")
    )
  )
}

# we build our app
shinyApp(
  ui = fluidPage(
    fluidRow(
      column(
        width = 6,
        align = "center",
        br(),
        my_card("blablabla. PouetPouet Pouet.")
      )
    )
  ),
  server = function(input, output) {}
)
```

and desesperately see that nothing is displayed. If you remember, this was expected since
shiny does not contain bootstrap 4 dependencies and this card is unfortunately a
bootstrap 4 object. Don't panic! We just need to tell shiny to load the css we need to display
this card (if required, we could include the javascript as well). We could use either
`includeCSS()`, `tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"))`. See
more [here](https://shiny.rstudio.com/articles/css.html).


```r
shinyApp(
  ui = fluidPage(
    # load the css code
    includeCSS(path = "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"),
    fluidRow(
      column(
        width = 6,
        align = "center",
        br(),
        my_card("blablabla. PouetPouet Pouet.")
      )
    )
  ),
  server = function(input, output) {}
)
```

The card is ugly (which is another problem we will fix later) but at least displayed.

When I say this approach is dirty, it is because it will not be easily re-usable by others.
Instead, we prefer a packaging approach, like in the next section.

## The clean approach

We will use the `htmlDependency` and `attachDependencies` functions from htmltools.
The htmlDependency takes several arguments:

- the name of your dependency
- the version (useful to remember on which version it is built upon)
- a path to the dependency (can be a CDN or a local folder)
- script and stylesheet to respectively pass css and scripts


```r
# handle dependency
card_css <- "bootstrap.min.css"
bs4_card_dep <- function() {
  htmlDependency(
    name = "bs4_card",
    version = "1.0",
    src = c(href = "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/"),
    stylesheet = card_css
  )
}
```

We create the card tag and give it the bootstrap 4 dependency through the `attachDependencies()` function. In recent version of htmltools, we may simply use
`tagList(tag, deps)` instead.


```r
# create the card
my_card <- function(...) {
  cardTag <- withTags(
    div(
      class = "card border-success mb-3",
      div(class = "card-header bg-transparent border-success"),
      div(
        class = "card-body text-success",
        h3(class = "card-title", "title"),
        p(class = "card-text", ...)
      ),
      div(class = "card-footer bg-transparent border-success", "footer")
    )
  )
  
  # attach dependencies (old way)
  # htmltools::attachDependencies(cardTag, bs4_card_dep())
  
  # simpler way
  tagList(cardTag, bs4_card_dep())
  
}
```

We finally run our app:


```r
# run shiny app 
ui <- fluidPage(
  title = "Hello Shiny!",
  fluidRow(
    column(
      width = 6,
      align = "center",
      br(),
      my_card("blablabla. PouetPouet Pouet.")
    )
  )
)

shinyApp(ui, server = function(input, output) { })
```

With this approach, you could develop a package of custom dependencies that people
could use when they need to add custom elements in shiny.


## Another example: Importing HTML dependencies from other packages

You may know shinydashboard, a package to design dashboards with shiny. In the following, we would like to integrate the box component in a classic Shiny App (without the dashboard layout). However, if you try to include the Shinydashboard box tag, you will notice that nothing is displayed since Shiny does not have shinydashboard dependencies. Fortunately htmltools contains a function, namely `findDependencies` that looks for all dependencies attached to a tag. How about extracting shinydashboard dependencies? Before going futher, let's define the basic skeleton of a shinydashboard:


```r
shinyApp(
  ui = dashboardPage(
    dashboardHeader(),
    dashboardSidebar(),
    dashboardBody(),
    title = "Dashboard example"
  ),
  server = function(input, output) { }
)
```

We don't need to understand shinydashboard details. However, if you are interested to dig in, [help yourself](https://rstudio.github.io/shinydashboard/). What is important here is the main
wrapper function `dashboardPage`. (You should already be familiar with `fluidPage`, another wrapper function). We apply `findDependencies` on `dashboardPage`.


```r
deps <- findDependencies(
  dashboardPage(
    header = dashboardHeader(), 
    sidebar = dashboardSidebar(), 
    body = dashboardBody()
  )
)
deps
```

deps is a list containg 4 dependencies:

- [Font Awesome](https://fontawesome.com) handles icons
- [Bootstrap](https://getbootstrap.com/docs/3.3/) is the main HTML/CSS/JS template. Importantly,
please note the version 3.3.7, whereas the current is 4.3.1
- [AdminLTE](https://adminlte.io) is the dependency containg HTML/CSS/JS related to the admin template.
It is closely linked to Bootstrap 3. 
- shinydashboard, the CSS and javascript necessary for shinydashboard to work properly. In practice,
integrating custom HTML templates to shiny does not usually work out of the box for many reasons (Explain why!) and some modifications are necessary.


```
[[1]]
List of 10
$ name      : chr "font-awesome"
$ version   : chr "5.3.1"
$ src       :List of 1
..$ file: chr "www/shared/fontawesome"
$ meta      : NULL
$ script    : NULL
$ stylesheet: chr [1:2] "css/all.min.css" "css/v4-shims.min.css"
$ head      : NULL
$ attachment: NULL
$ package   : chr "shiny"
$ all_files : logi TRUE
- attr(*, "class")= chr "html_dependency"
[[2]]
List of 10
$ name      : chr "bootstrap"
$ version   : chr "3.3.7"
$ src       :List of 2
..$ href: chr "shared/bootstrap"
..$ file: chr "/Library/Frameworks/R.framework/Versions/3.5/Resources/library/shiny/www/shared/bootstrap"
$ meta      :List of 1
..$ viewport: chr "width=device-width, initial-scale=1"
$ script    : chr [1:3] "js/bootstrap.min.js" "shim/html5shiv.min.js" "shim/respond.min.js"
$ stylesheet: chr "css/bootstrap.min.css"
$ head      : NULL
$ attachment: NULL
$ package   : NULL
$ all_files : logi TRUE
- attr(*, "class")= chr "html_dependency"
[[3]]
List of 10
$ name      : chr "AdminLTE"
$ version   : chr "2.0.6"
$ src       :List of 1
..$ file: chr "/Library/Frameworks/R.framework/Versions/3.5/Resources/library/shinydashboard/AdminLTE"
$ meta      : NULL
$ script    : chr "app.min.js"
$ stylesheet: chr [1:2] "AdminLTE.min.css" "_all-skins.min.css"
$ head      : NULL
$ attachment: NULL
$ package   : NULL
$ all_files : logi TRUE
- attr(*, "class")= chr "html_dependency"
[[4]]
List of 10
$ name      : chr "shinydashboard"
$ version   : chr "0.7.1"
$ src       :List of 1
..$ file: chr "/Library/Frameworks/R.framework/Versions/3.5/Resources/library/shinydashboard"
$ meta      : NULL
$ script    : chr "shinydashboard.min.js"
$ stylesheet: chr "shinydashboard.css"
$ head      : NULL
$ attachment: NULL
$ package   : NULL
$ all_files : logi TRUE
- attr(*, "class")= chr "html_dependency"
```

Below, we attach the dependencies to the `box` with `tagList`, as shown above. Notice that our custom `box` does not contain all parameters from shinydashboard but this is not what matters in this example.


```r
my_box <- function(title, status) {
  tagList(box(title = title, status = status), deps)
}
ui <- fluidPage(
  titlePanel("Shiny with a box"),
  my_box(title = "My box", status = "danger"),
)
server <- function(input, output) {}
shinyApp(ui, server)
```

Now, you may imagine the possibilities are almost unlimited! Interestingly, this
is the approach we use in [shinyWidgets](https://github.com/dreamRs/shinyWidgets/blob/master/R/useBs4Dash.R) for
the `useBs4Dash` function and other related tools.

## Suppress dependencies

In rare cases, you may need to remove an existing dependency (conflict). The `suppressDependencies` function allows to perform that task. For instance, [shiny.semantic](https://github.com/Appsilon/shiny.semantic) built on top of 
semantic ui is not compatible with Bootstrap. Below, we remove the AdminLTE dependency
from a shinydashboard page and nothing is displayed (as expected):


```r
shinyApp(
  ui = dashboardPage(
    dashboardHeader(),
    dashboardSidebar(),
    dashboardBody(suppressDependencies("AdminLTE")),
    title = "Dashboard example"
  ),
  server = function(input, output) { }
)
```

<!--chapter:end:htmltools-dependencies.Rmd-->

# Other tools {#htmltools-other-tools}

## CSS
- See [cascadess](https://github.com/nteetor/cascadess) to customize the style of tags


```r
ui <- list(
  cascadess(),
  h4(
    .style %>%
      font(case = "upper") %>%
      border(bottom = "red"),
    "Etiam vel tortor sodales tellus ultricies commodo."
  )
)
```

<!--chapter:end:htmltools-other-tools.Rmd-->

# (PART\*) Practice {-}

In this chapter, you will learn how to build your own html templates taken from the web and package them, so that they can be re-used at any time by anybody.

<!--chapter:end:custom-templates.Rmd-->

# Template selection {#custom-templates-selection}
There exists tons of HTML templates over the web. However, only a few part will be suitable for shiny, mainly because of what follows:

* shiny is built on top of [bootstrap 3](https://getbootstrap.com/docs/3.3/) (HTML, CSS and Javascript framework), meaning that going for another framework might
not be straightforward. However, shinymaterial and shiny.semantic are examples showing
this can be possible.
* shiny relies on [jQuery](https://jquery.com) (currently v 1.12.4 for shiny, whereas the latest version is 3.3.1). Consequently, all templates based upon React, Vue and other Javascript framework will not be natively supported. Again, there exist some [examples](https://github.com/alandipert/react-widget-demo/blob/master/app.R) for React with shiny and more generally,
the [reactR](https://react-r.github.io/reactR/) package developed by Kent Russell and Alan Dipert from RStudio.

See [the github repository](https://github.com/rstudio/shiny/tree/master/inst/www/shared) for more details about all dependencies related to the shiny package.

> Notes: As shiny depends on Bootstrap 3.3.7, we recommand the user who would like to
experiment Bootstrap 4 features to be particularly careful about potential incompatibilies. See a working example here with [bs4Dash](https://github.com/RinteRface/bs4Dash).

A good source of **open source** HTML templates is [Colorlib](https://colorlib.com) and [Creative Tim](https://www.creative-tim.com/bootstrap-themes/free). You might also buy your template, but forget about the packaging option, which would be illegal in this particular case.

<!--chapter:end:custom-templates-intro.Rmd-->

# Define dependencies {#custom-templates-dependencies}

<!--chapter:end:custom-templates-dependencies.Rmd-->

# Template skeleton {#custom-templates-skeleton}

<!--chapter:end:custom-templates-skeleton.Rmd-->

# Develop custom input widgets {#custom-templates-inputs}

## How does Shiny handle inputs?

## How to add new input to Shiny?

<!--chapter:end:custom-templates-inputs.Rmd-->

# Testing templates elements {#custom-templates-testing}

<!--chapter:end:custom-templates-testing.Rmd-->

