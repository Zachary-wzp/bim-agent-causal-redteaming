require_relative '../scripts/validate_content'

# Also protect direct `jekyll build` / `serve`, not just CI.
Jekyll::Hooks.register :site, :after_init do |site|
  if site.config['unpublished']
    raise Jekyll::Errors::FatalException, 'Building unpublished research content is disabled.'
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  validator = ContentValidator.new(site.source)
  unless validator.validate
    raise Jekyll::Errors::FatalException, "Content validation failed:\n#{validator.errors.join("\n")}"
  end
end
