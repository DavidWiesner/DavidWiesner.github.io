module PagesModelViewAddons
  def friendly_date
	date
  end
end
Ruhoh.model('pages').send(:include, PagesModelViewAddons)