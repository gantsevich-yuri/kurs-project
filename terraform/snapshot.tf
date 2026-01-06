resource "yandex_compute_snapshot_schedule" "vm_snap_app1" {
  name = "snap-app1"

  schedule_policy {
    expression = "5 18 * * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "dialy-vm-app1-snapshot"
  }

  disk_ids = [yandex_compute_instance.app1.boot_disk[0].disk_id]
}