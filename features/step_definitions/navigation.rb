Then /^I swipe down inside home$/ do
    scroll("view marked:'teaserPageScrollView'", :down)
    #scroll("UIScrollView marked:'teaserPageScrollView'", :down)
end

Then /^I scroll down the quantity$/ do
    scroll("UIScrollView index:1", :down)
end

Then /^I swipe the related items$/ do
    scroll("UIScrollView index:1", :right)
end
