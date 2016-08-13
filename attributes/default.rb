default["java"]["install_flavor"] = "oracle"
default["java"]["jdk_version"] = "8"
default["java"]["java_home"] = "/usr/bin/java"
default["java"]["oracle"]["accept_oracle_download_terms"] = true

include_attribute "nettyapp::deploy"
