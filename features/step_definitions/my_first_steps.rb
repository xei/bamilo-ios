Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(STEP_PAUSE)
end

Then /^Test 1$/ do
    puts "Start"
    puts STRING_MY_FAVOURITES
end