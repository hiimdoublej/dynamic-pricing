## Getting familar with the code
After reading the root level Q&A and the original README.md, I skimmed around the repository to see what this rails application was about.

I started from the tests, hoping that it will tell me how to trace the code in a application that I am not yet familiar with. Eventually I got to `app/controllers/pricing_controller.rb` and now I roughly have an idea of where the implementation should start from.

I also skimmed around the root level, one thing that I didn't quite comprehend upfront is the Rakefile, so I research it a bit using AI tools. My understanding at this point is that `rake` is like a ruby cli system in which I can register commands that I need. This should come in handy when I need something like a cronjob cleanup or a one time data export. Similar to manage.py commands with Django. I also used to have something like this with Flask + Click.

## Try out the application

Then I figured is time to try out the application!
I followed the quickstart instructions on the original README.md and executed the tests + `curl` successfully.

Here are a few things that I noticed along the way:
- The rails logging includes much extra information that isn't normally given, such as where the response was returned, the time that it took to render the response, lookup ActiveRecord, and memory allocations. This seems very helpful for a quick glance on performance during development.
```
Started GET "/pricing?period=Summer&hotel=FloatingPointResort&room=SingletonRoom" for 172.17.0.1 at 2025-12-31 07:31:20 +0000
Processing by PricingController#index as */*
  Parameters: {"period"=>"Summer", "hotel"=>"FloatingPointResort", "room"=>"SingletonRoom"}
Completed 200 OK in 1ms (Views: 0.3ms | ActiveRecord: 0.0ms | Allocations: 260)
```
- I tried changing the pricing from 12000 to 13000, and altough there was no visible logs for code reload, the pricing was updated. I researched via AI to see that auto reload and the logs for auto reload are controller by different configs. Also, the auto reload felt faster than Flask and Django (not sure if it's because this is a very simple application).
