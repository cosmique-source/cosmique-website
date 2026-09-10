module.exports = function(eleventyConfig) {
  // Copy static assets
  eleventyConfig.addPassthroughCopy("src/css");
  eleventyConfig.addPassthroughCopy("src/js");
  eleventyConfig.addPassthroughCopy("src/assets");
  eleventyConfig.addPassthroughCopy("src/CNAME");
  // Orbit turnkey installer — served raw at /orbit/install.sh
  // (curl -fsSL https://cosmique.io/orbit/install.sh | bash).
  // Source of truth is the orbit repo's deploy/docker-installer branch.
  eleventyConfig.addPassthroughCopy("src/orbit/install.sh");

  // Split "Title — body" feature strings in templates
  eleventyConfig.addFilter("split", (str, sep) => String(str).split(sep));

  // Add content.json as global data
  const content = require("./content.json");
  eleventyConfig.addGlobalData("site", content);

  // Apps rendered by the generic apps.njk template. Orbit has its own
  // dedicated product page (src/orbit.njk) and is excluded here.
  eleventyConfig.addGlobalData(
    "appsStandard",
    content.apps.filter((app) => app.slug !== "orbit")
  );

  // Orbit is live (2026-09-10). `orbitLive` is kept for the legal/support pages,
  // whose nav shows the Pricing link only when the product page is published.
  eleventyConfig.addGlobalData("orbitLive", true);

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
