# Website Sitemap Scraper

A script to scrape a site's html from its sitemap, and build a static version with directory indexes.
We assume the website's protocol and hostname are the same as listed in its sitemap.

### Setup

- [Install Node](Node.js Installer)
- `npm install coffee-script -g`
- run `npm install`

### Scraping

- run `coffee index.coffee <URL> <sitemap path (optional)> <build dir (optional>`
- files will be built to the `./build` directory unless the build path is specified in process.argv

