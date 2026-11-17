# xueshi.dev-apps

The list of the author's macOS apps, as one file: `apps.json`.

The "More Apps" page inside each app (the
[MoreAppsKit](https://github.com/XueshiQiao/MoreAppsKit) Swift package) downloads
this file to know which apps to show, in which order, and where to get them.
Changing the file changes the page in every installed app, without an app
update.

The apps read the file from four addresses, because no single host is
reachable from every network: GitHub's own raw address, and the jsDelivr
network, which mirrors public GitHub repositories, under three host names.

| Host | Address the apps read |
|---|---|
| GitHub | `https://raw.githubusercontent.com/XueshiQiao/xueshi.dev-apps/main/apps.json` |
| jsDelivr | `https://cdn.jsdelivr.net/gh/XueshiQiao/xueshi.dev-apps@main/apps.json` |
| jsDelivr | `https://fastly.jsdelivr.net/gh/XueshiQiao/xueshi.dev-apps@main/apps.json` |
| jsDelivr | `https://gcore.jsdelivr.net/gh/XueshiQiao/xueshi.dev-apps@main/apps.json` |

An app asks all of them at once and uses the answer with the highest
`revision`.

**These addresses must never change**: apps already installed keep reading
them. Do not rename the repository, the branch (`main`) or the file.

## Changing the list

1. Edit `apps.json`. The order of `apps` is the order on the page.
2. **Increase `revision`.** An app ignores a list whose revision is not higher
   than the one it already has.
3. Commit, then run:

   ```bash
   ./publish.sh
   ```

   It pushes to GitHub, asks jsDelivr to refresh its copy (it otherwise keeps
   the old file for up to 12 hours) and checks that every address above
   returns the new revision.

The format of an entry, and the rules the apps apply when reading it (https
only, unknown entries skipped), are described in MoreAppsKit's README.

MoreAppsKit also carries a copy of this file inside the package, so the page
works with no network. That copy is only a starting point; it is refreshed
from this repository when a new version of the package is released.

An incompatible change of the format must go into a file with a new name, so
apps already in use keep reading `apps.json` as it is.

## Why not Gitee

Gitee was tried as a second host on 2026-11-17 and does not work. It treats an
app reading a raw file as link abuse ("外链滥用"), makes the repository private
and refuses to make it public again.

## License

GPL-3.0, the same license as the apps. See [LICENSE](LICENSE).
