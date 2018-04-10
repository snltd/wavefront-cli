MERP MERP
resource "wavefront_dashboard" "9f8d3f29-d965-4f7e-8473-43571e431b99" {
  name = "JPC Website Host"
  description = "overview of SmartOS zones"
  url = "jpc-webhost"
  section = [
    { name = "Memory"
      row = [
        { chart = [
          {
            units = "B"
            name = "Swap Free"
            description = "Remember, on Solaris, \"swap\" means backing store, so this is all memory."
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "New Query"
            query = "ts(\"tenant.swapresv.value\", env=${env}) - ts(\"tenant.swapresv.usage\", env=${env})"
          }]
          },
          {
            units = ""
            name = "Free Physical Memory"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "physical memory"
            query = "ts(\"tenant.physicalmem.value\", env=${env}) - ts(\"tenant.physicalmem.usage\", env=${env})"
          },
          {
            scatter_plot_source = "Y"
            query_builder_enabled = true
            source_description = ""
            name = "out of memory"
            query = "0"
          }]
          },
          {
            units = ""
            name = "times over memory"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "times over memory"
            query = "deriv(ts(\"tenant.memory_cap.nover\", env=${env}))"
          }]
          }]
        },
        { chart = [
          {
            units = "B"
            name = "Sinatra application memory"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "New Query"
            query = "sum(ts(\"process.memory.pr_rssize.*\", svc=\"svc:/application/sinatra/*\" and env=${env}), svc)"
          }]
          },
          {
            units = ""
            name = "top memory consumers"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "by process name"
            query = "sum(ts(\"process.memory.pr_rssize.*\", env=${env}), metrics)"
          }]
          }]
        }]
    },
    { name = "nginx"
      row = [
        { chart = [
          {
            units = "req/s"
            name = "\"200\" HTTP requests"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "Query"
            query = "rate(ts(\"nginx.code.200\"))"
          }]
          },
          {
            units = "ms"
            name = "request latency"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "total response time"
            query = "ts(\"nginx.time.response.*\")"
          },
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "upstream response time"
            query = "ts(\"nginx.time.upstream_response.*\")"
          }]
          },
          {
            units = "req/s"
            name = "HTTP Errors"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "40x"
            query = "ceil(rate(ts(\"nginx.code.4*\")))"
          },
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "50x"
            query = "ceil(rate(ts(\"nginx.code.5*\")))"
          }]
          }]
        }]
    },
    { name = "Processes and Services"
      row = [
        { chart = [
          {
            units = "processes"
            name = "processes"
            description = "number active processes in zone"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = true
            source_description = ""
            name = "running processes"
            query = "ts(\"tenant.nprocs.usage\", env=${env})"
          }]
          },
          {
            units = "services"
            name = "Service States"
            description = "count of services in each possible state. Disabled service are not shown,"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "New Query"
            query = "ts(\"smf.svcs.*\", env=${env})"
          }]
          }]
        }]
    },
    { name = "Network"
      row = [
        { chart = [
          {
            units = "bytes"
            name = "Network In"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "New Query"
            query = "deriv(ts(\"network.*.net0.rbytes64\", env=${env}))"
          }]
          },
          {
            units = "bytes"
            name = "Network Out"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "network out"
            query = "deriv(ts(\"network.*.net0.obytes64\", env=${env}))"
          }]
          }]
        },
        { chart = [
          {
            units = "s"
            name = "Puppet Run Time"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "time"
            query = "ts(\"puppet.time.*\", env=${env})"
          }]
          },
          {
            units = "Units"
            name = "Puppet Changes"
            description = ""
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "New Query"
            query = "ts(\"puppet.changes.total\")"
          }]
          }]
        }]
    },
    { name = "Page Impressions"
      row = [
        { chart = [
          {
            units = ""
            name = "Most read posts"
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "Query"
            query = "sum(ts(\"nginx.code.200\", vhost=sysdef.xyz and path=\"/post/*\"), pointTags)"
          }]
          }]
        },
        { chart = [
          {
            units = ""
            name = "most viewed pieces"
            description = ""
            source = [
          {
            scatter_plot_source = "Y"
            query_builder_enabled = false
            source_description = ""
            name = "Query"
            query = "sum(ts(\"nginx.code.200\", vhost=\"rdfisher.co.uk\" and path=\"/piece/*\"), pointTags)"
          }]
          }]
        }]
    }]
  tags = []
}
