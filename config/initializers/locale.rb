# Tell the I18n library where to find your translations
I18n.load_path += Dir[ File.join(RAILS_ROOT, 'locales', '**', '*.{rb,yml}') ]