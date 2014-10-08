Then /^I swipe down inside home$/ do
    scroll("UIScrollView marked:'teaserPageScrollView'", :down)
end

Then /^I scroll down the quantity$/ do
    scroll("UIScrollView index:1", :down)
end