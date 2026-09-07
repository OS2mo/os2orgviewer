# Configuration

The organisation chart is configured entirely with environment variables. What each option
does, seen from the user of the chart, is described in
[the OS2mo documentation](https://rammearkitektur.docs.magenta.dk/os2mo/features/org-chart.html);
this page is the reference for the variables that turn those options on and off.

Every option can be set per deployment, so the same codebase can serve several charts - e.g.
the administrative organisation and the MED organisation - with different roots, different
filtering and different branding.

## Setting the variables

Before the build, set them in `app/.env` (see [.env.example](../.env.example)) or, when
running through Docker Compose, in the `orgviewer` service's `environment:` block in
[docker-compose.yml](../../docker-compose.yml).

In a deployed container the application is already built, and
[30-sed-on-index-html.sh](../../docker/30-sed-on-index-html.sh) patches the values into the
built `index.html` on startup. Use the same `VUE_APP_*` names there. Six variables also have
an older deployment-facing alias, which takes precedence when set: `GLOBAL_API_URL`,
`GLOBAL_API_ROOT_UUID`, `GLOBAL_ORG_PERSON_RELATION`, `GLOBAL_APP_TITLE`,
`KEYCLOAK_CLIENT_ID` and `KEYCLOAK_CLIENT_SECRET`. The aliases work at runtime only.

> **Note:** the entrypoint script matches the exact quoting used in `app/public/index.html`
> (`VUE_APP_X: '...'`, single quotes). `sed` exits 0 when a pattern does not match, so if the
> quoting in the template is changed without changing the script, the overrides silently do
> nothing and the container starts with its build-time values. Keep the two files in sync.

## Value formats

**Lists** are parsed by `convertToArray()` in [helpers.js](../src/helpers.js), which strips
quotes, square brackets and *all* spaces and then splits on comma. These are therefore
equivalent:

```
VUE_APP_HIDE_ORG_UNIT_UUIDS='["uuid-a", "uuid-b"]'
VUE_APP_HIDE_ORG_UNIT_UUIDS=uuid-a,uuid-b
```

Because spaces are stripped, a list value cannot contain a space or a comma. This matters for
`VUE_APP_HIDE_ORG_UNITS_BY_NAME`, where `_leder afdeling` would be matched as
`_lederafdeling` and never hit anything.

**Booleans** are parsed by `convertToBoolean()`, which is a strict comparison against the
lowercase string `true`. Any other value - including `True`, `TRUE` and `1` - is false.

## Variables

### Connection and authentication

| Variable | Format | Default | Description |
| --- | --- | --- | --- |
| `VUE_APP_API_BASEURL` | url | `https://moratest.magenta.dk` | Base URL of the OS2MO instance. GraphQL is queried at `<baseurl>/graphql/v22` and tokens are fetched from `<baseurl>/auth`. |
| `VUE_APP_KEYCLOAK_CLIENT_ID` | string | none | Keycloak client used to read data from MO. The client authenticates with `client_credentials` against realm `mo` and needs the `reader` role. |
| `VUE_APP_KEYCLOAK_CLIENT_SECRET` | string | none | Secret for the above client. It is served to the browser in `index.html`, so the client must be a read-only one. |

### Which part of the organisation to show

| Variable | Format | Default | Description |
| --- | --- | --- | --- |
| `VUE_APP_ROOT_UUID` | uuid | none | The org unit the tree starts from. Also limits the org unit search, which uses it as `ancestor` filter. |
| `VUE_APP_ORG_PERSON_RELATION` | `engagement`, `association` or `both` | `engagement` | Whether people are shown in a unit by their engagements, their associations, or both. |
| `VUE_APP_ORG_UNIT_HIERARCHY_UUIDS` | list of uuids | empty | Only show units marked with one of these `org_unit_hierarchy` classes, e.g. the line organisation or the MED organisation. |
| `VUE_APP_HIDE_ORG_UNIT_UUIDS` | list of uuids | empty | Units to remove from the tree. |
| `VUE_APP_HIDE_ORG_UNITS_BY_NAME` | list of strings | empty | Remove units whose name *contains* one of these substrings, e.g. `_leder`. |
| `VUE_APP_HIDE_ORG_UNIT_LEVELS` | list of uuids | empty | Remove units whose `org_unit_level` is one of these classes. Units with no level are kept. |
| `VUE_APP_SORT_SPECIFIC_UNITS_TO_BOTTOM` | list of uuids | empty | These units are sorted last among their siblings instead of alphabetically. |

### What to show about people and units

| Variable | Format | Default | Description |
| --- | --- | --- | --- |
| `VUE_APP_SHOW_NICKNAME` | boolean | `false` | Show a person's nickname instead of the CPR name when one is set in MO. Also applies to search results. |
| `VUE_APP_REMOVE_ENGAGEMENT_TYPE_UUID` | list of uuids | empty | Hide engagements of these `engagement_type` classes from the person lists, e.g. robot or external accounts. |
| `VUE_APP_REMOVE_MANAGER_ENGAGEMENT` | boolean | `false` | Show a manager only in the manager list, not additionally in the engagement list. Only use this with `VUE_APP_ORG_PERSON_RELATION=engagement`; it does not work with associations. |
| `VUE_APP_SHOW_EXTENSION_1` | boolean | `false` | Show the engagement's `extension_1` instead of its job function (Silkeborg). |
| `VUE_APP_SHOW_EXTENSION_3_VIBORG` | boolean | `false` | Show the engagement's `extension_3` instead of its job function (Viborg). Takes precedence over `VUE_APP_SHOW_EXTENSION_1` if both are set. |
| `VUE_APP_HIDDEN_ADDRESS_TYPE_USER_KEYS` | list of `address_type` user keys | empty | Hide these address types wherever addresses are listed - both on units and on people. Example: `'["EmailEmployee", "PhoneEmployee"]'`. |
| `VUE_APP_REMOVE_ORG_UNIT_EMAIL` | boolean | `false` | Hide the unit email, i.e. the address with user key `EmailUnit`. Equivalent to adding `EmailUnit` to `VUE_APP_HIDDEN_ADDRESS_TYPE_USER_KEYS`. |
| `VUE_APP_REMOVE_PERSON_COUNT` | boolean | `false` | Hide the number of employees/associated people on each unit in the tree. |
| `VUE_APP_REMOVE_CHILDREN_COUNT` | boolean | `false` | Hide the number of sub units on each unit in the tree. |

### Look and feel

| Variable | Format | Default | Description |
| --- | --- | --- | --- |
| `VUE_APP_TITLE` | string | none | Application title. Shown in the UI header, as the HTML document title and in the `<noscript>` message. |
| `VUE_APP_THEME_CSS` | path or url | none | Stylesheet with custom theme styles, loaded as `<link id="oc-custom-style">`. Copy `src/assets/default-theme.css` and edit it to make your own. Files in `app/public/` are served from the site root, so a bare filename works. |
| `VUE_APP_LOGO_PATH` | path or url | none | Branding image shown in the header. |
| `VUE_APP_FAVICON_PATH` | path or url | none | Favicon, usually `favicon.ico`. |
| `VUE_APP_TREE_LAYOUT` | `vertical`, `horizontal` or `hybrid` | `vertical` | Direction the tree unfolds in. `horizontal` and `hybrid` both give the horizontal layout; any other value gives the vertical one. |

### Build only

| Variable | Format | Default | Description |
| --- | --- | --- | --- |
| `NODE_ENV` | `development` or `production` | `development` | Standard Vue CLI build mode. |
| `VUE_APP_VERSION` | string | `package.json` version | Set by [vue.config.js](../vue.config.js) and written to the `description` meta tag. Not meant to be set by hand. |

## Example

A minimal deployment, showing both engagements and associations, with local branding and the
employee email address hidden:

```
VUE_APP_API_BASEURL=https://os2mo.example.dk
VUE_APP_KEYCLOAK_CLIENT_ID=orgviewer
VUE_APP_KEYCLOAK_CLIENT_SECRET=<secret>
VUE_APP_ROOT_UUID=f06ee470-9f17-566f-acbe-e938112d46d9
VUE_APP_ORG_PERSON_RELATION=both
VUE_APP_TITLE=Andeby Kommune
VUE_APP_THEME_CSS=andeby.css
VUE_APP_LOGO_PATH=andeby_logo.svg
VUE_APP_HIDDEN_ADDRESS_TYPE_USER_KEYS='["EmailEmployee"]'
VUE_APP_SHOW_NICKNAME=true
```
