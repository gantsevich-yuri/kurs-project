resource "yandex_compute_snapshot_schedule" "daily_snapshots" {
  name = "daily-snapshots"

  schedule_policy {
    expression = "35 2 * * *"
  }

  retention_period {
    max_age = "168h"
  }

  snapshot_count = 7

  disk_selector {
    labels = {
      backup = "snapshot"
    }
  }
}
