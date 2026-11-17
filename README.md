# apps

The list of the author's macOS apps, as one file: `apps.json`.

The "More Apps" page inside each app (the
[MoreAppsKit](https://github.com/XueshiQiao/MoreAppsKit) Swift package) downloads
this file to know which apps to show, in which order, and where to get them.
Changing the file changes the page in every installed app, without an app
update.

The same repository is published in two places, because neither is reachable
from every network:

| Where | Address the apps read |
|---|---|
| GitHub | `https://raw.githubusercontent.com/XueshiQiao/apps/main/apps.json` |
| Gitee | `https://gitee.com/XueshiQiao/apps/raw/main/apps.json` |

An app asks both and uses the answer with the highest `revision`.

**These two addresses must never change**: apps already installed keep reading
them. Do not rename the repository, the branch (`main`) or the file.

## Changing the list

1. Edit `apps.json`. The order of `apps` is the order on the page.
2. **Increase `revision`.** An app ignores a list whose revision is not higher
   than the one it already has.
3. Commit, then push to both places:

   ```bash
   git push origin main    # GitHub
   git push gitee main     # Gitee
   ```

4. Check that both addresses in the table above return the new file.

The format of an entry, and the rules the apps apply when reading it (https
only, unknown entries skipped), are described in MoreAppsKit's README.

MoreAppsKit also carries a copy of this file inside the package, so the page
works with no network. That copy is only a starting point; it is refreshed
from this repository when a new version of the package is released.

An incompatible change of the format must go into a file with a new name, so
apps already in use keep reading `apps.json` as it is.
