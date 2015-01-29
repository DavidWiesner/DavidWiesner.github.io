module PagesModelViewAddons
  def day_month
    date.strftime("%d. %b")
  end
end
Ruhoh.model('pages').send(:include, PagesModelViewAddons)