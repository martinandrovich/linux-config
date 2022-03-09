# linux-config

## Intallation

| Name | Size      | Type    | Location                | Use as                      | Mount point |
|------|-----------|---------|-------------------------|-----------------------------|-------------|
| EFI* | `100 MB`  | Primary | Beginning of this space | EFI System Partition        |             |
| Root | `>50 GB`  | Primary | Beginning of this space | Ext4 journalist file system | `/`         |
| Swap | `8-32 GB` | Primary | Beginning of this space | swap area                   |             |

*\* only if Windows has not created EFI partition.*

## Configuration script

```
curl -OL https://raw.githubusercontent.com/<username>/<repo-name>/<branch-name>/path/to/file
chmod +x setup.bash
sudo ./setup.bash
```
