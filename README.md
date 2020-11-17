# bash-scraper

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [bash-scraper](#bash-scraper)
- [How to use it](#how-to-use-it)
- [Dependencies](#dependencies)

<!-- markdown-toc end -->

This is a scraper we (Ecce, Linda, Giacomo; aka Team 7) built in
shell. It scrapes down all recipes from [recept.se](https://recept.se)
to disk, and allows to easily search for recipes.

# How to use it

First, run `webscraper` (stage 1), once that is done, run
`webscraper_stage_2`. Once both are done, you can use `search.sh` to
search for a recipe. `search` accepts regexps.

# Dependencies

You will need a command called `jq` to successfully run stage 2.
