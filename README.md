Netty Cookbook for Amazon OpsWorks
===============================

Fuel Powered is testing out Netty for one of our services, using Gradle for dependency management and building. This cookbook is a first attempt to get our experiment set up on AWS Opsworks. It may or may not work for you, or even us.

Dependencies
-----------------------------
This cookbook depends on the following:

- `gradle`: https://github.com/evertrue/et_gradle-cookbook
- `monit`: https://github.com/Grantoo/chef-monit
- `java`: https://supermarket.chef.io/cookbooks/java

Select the `Custom` Layer Type
-----------------------------
When you make your Layer in OpsWorks, be sure to select Other > Custom, rather than "Java" or some other pre-defined stack. 

Custom Chef Recipes Setup
-----------------------------
To deploy your app, you'll have to make sure 2 of the recipes in this cookbook are run.

1. `nettyapp::configure` should run during the configuration phase of your node in OpsWorks
2. `nettyapp::deploy` should run during (every) deployment phase of your node.

Databag Setup
-----------------------------
This cookbook relies on a databag which you should set in Amazon OpsWorks as your Stack's "Custom Chef JSON".

Example Opsworks databag:

```json
{
  "deploy": {
    "YOUR_APPLICATION_SHORT_NAME": {
      "application_type": "nettyapp",
      "nettyapp": "MyNettyServer",
      "test_url": "/",
      "env": {
        "APP_ENV": "production",
        "PORT": 80
        "EXTRA_ENV_VAR": "value of extra environment variable"
      },
      "config": ["other"]
    }
  }
  "other": {
    "option1": "value1"
  }
}
```

Important note: this cookbook double-checks that your `application_type` is set to `nettyapp`. If `application_type` is not set to `nettyapp`, none of the cookbook will run for that app. `test_url` will be tested by monit to ensure server is still up (default "/").

If you include a layers key, only matching layer will deploy this application.  E.g.

```json
{
  "deploy": {
    "blog": {
      "application_type": "nettyapp",
      "layers": ["blog-server"]
    }
  }
}
```

The `blog` app will only deploy onto the `blog-server` layer.

If you include a config key, the matching root-level values will be copied to the properties file as sections, allowing other cookbook configuration to be made available to your application. e.g.

```json
{
  "deploy": {
    "blog": {
      "config": ["wordpress"],
    }
  },
  "wordpress": {
    "database": "db.host"
  }
}
```

The resulting blog.properties file will contain the following sections:

```
[wordpress]
database=db.host
```

How it Works
-----------------------------
This cookbook builds and runs a netty server app in the following way:

- An `APPNAME.properties` file is created using your databag and output at `/srv/www/APPNAME/shared/config/APPNAME.properties`
- A `nettyapp-APPNAME-server-daemon` shell script is created and placed in  `/srv/www/APPNAME/current/`, which handles start and restart commands, by calling  `gradle run and outputting logs to `/srv/www/APPNAME/shared/log/nettyapp.log`
- A `nettyapp_APPNAME_server.monitrc` monit script is created, which utilizes the `nettyapp-APPNAME-server-daemon` script for startup and shutdown, and is placed in `/etc/monit.d` or `/etc/monit/conf.d`, depending on your OS (defined in the `monit` cookbook)
- `monit` is restarted, which incorporates the the new files.


License and Author
===============================
Author:: Shealen Clare
Inspired by:: https://github.com/juniorrobot/chef-goapp, by authors Matthew Moore & Geoff Hayes


Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
