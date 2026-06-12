module.exports = function(eleventyConfig) {
  // Copy static assets
  eleventyConfig.addPassthroughCopy("src/css");
  eleventyConfig.addPassthroughCopy("src/js");
  eleventyConfig.addPassthroughCopy("src/assets");
  eleventyConfig.addPassthroughCopy("src/CNAME");

  // Add content.json as global data
  const content = require("./content.json");
  eleventyConfig.addGlobalData("site", content);

  // Apps rendered by the generic apps.njk template. Orbit has its own
  // dedicated product page (src/orbit.njk) and is excluded here.
  eleventyConfig.addGlobalData(
    "appsStandard",
    content.apps.filter((app) => app.slug !== "orbit")
  );

  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      data: "_data"
    },
    templateFormats: ["njk", "html", "md"],
    htmlTemplateEngine: "njk",
    markdownTemplateEngine: "njk"
  };
};
