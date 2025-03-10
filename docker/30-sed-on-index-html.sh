#!/bin/sh

set -e

ME=$(basename $0)

VUE_APP_KEYCLOAK_CLIENT_ID=${KEYCLOAK_CLIENT_ID:-${VUE_APP_KEYCLOAK_CLIENT_ID}}
VUE_APP_KEYCLOAK_CLIENT_SECRET=${KEYCLOAK_CLIENT_SECRET:-${VUE_APP_KEYCLOAK_CLIENT_SECRET}}

VUE_APP_API_BASEURL=${GLOBAL_API_URL:-${VUE_APP_API_BASEURL}}
VUE_APP_ROOT_UUID=${GLOBAL_API_ROOT_UUID:-${VUE_APP_ROOT_UUID}}
VUE_APP_ORG_PERSON_RELATION=${GLOBAL_ORG_PERSON_RELATION:-${VUE_APP_ORG_PERSON_RELATION}}
VUE_APP_TITLE=${GLOBAL_APP_TITLE:-${VUE_APP_TITLE}}


replace_global_url() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_API_BASEURL: \".*\"#VUE_APP_API_BASEURL: '${VUE_APP_API_BASEURL}'#g" -i $index_file
}

replace_global_root_uuid() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_ROOT_UUID: \".*\"#VUE_APP_ROOT_UUID: '${VUE_APP_ROOT_UUID}'#g" -i $index_file
}

replace_org_unit_hierarchy_uuids() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  # NOTE: single quotes are necessary around $(...) since the value may contain JSON
  sed "s#VUE_APP_ORG_UNIT_HIERARCHY_UUIDS: \".*\"#VUE_APP_ORG_UNIT_HIERARCHY_UUIDS: '${VUE_APP_ORG_UNIT_HIERARCHY_UUIDS}'#g" -i $index_file
}

replace_global_app_title() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  # Check if variable is set, regardless of empty or not
  if [ ! -z "${VUE_APP_TITLE+x}" ]; then
    sed "s#VUE_APP_TITLE: \".*\"#VUE_APP_TITLE: '${VUE_APP_TITLE}'#g" -i $index_file
    sed "s#<title>.*</title>#<title>${VUE_APP_TITLE}</title>#g" -i $index_file
  fi

}

replace_global_replace_org_person_relation() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_ORG_PERSON_RELATION: \".*\"#VUE_APP_ORG_PERSON_RELATION: '${VUE_APP_ORG_PERSON_RELATION}'#g" -i $index_file
}

replace_tree_layout() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_TREE_LAYOUT: \".*\"#VUE_APP_TREE_LAYOUT: '${VUE_APP_TREE_LAYOUT}'#g" -i $index_file
}

replace_logo_path() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_LOGO_PATH: \".*\"#VUE_APP_LOGO_PATH: '${VUE_APP_LOGO_PATH}'#g" -i $index_file
}

replace_hide_org_unit_uuids() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  # NOTE: single quotes are necessary around $(...) since the value may contain JSON
  sed "s#VUE_APP_HIDE_ORG_UNIT_UUIDS: \".*\"#VUE_APP_HIDE_ORG_UNIT_UUIDS: '${VUE_APP_HIDE_ORG_UNIT_UUIDS}'#g" -i $index_file
}

replace_hide_org_units_by_name() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  # NOTE: single quotes are necessary around $(...) since the value may contain JSON
  sed "s#VUE_APP_HIDE_ORG_UNITS_BY_NAME: \".*\"#VUE_APP_HIDE_ORG_UNITS_BY_NAME: '${VUE_APP_HIDE_ORG_UNITS_BY_NAME}'#g" -i $index_file
}

replace_hide_org_unit_levels() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  # NOTE: single quotes are necessary around $(...) since the value may contain JSON
  sed "s#VUE_APP_HIDE_ORG_UNIT_LEVELS: \".*\"#VUE_APP_HIDE_ORG_UNIT_LEVELS: '${VUE_APP_HIDE_ORG_UNIT_LEVELS}'#g" -i $index_file
}

replace_sort_specific_units_to_bottom() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_SORT_SPECIFIC_UNITS_TO_BOTTOM: \".*\"#VUE_APP_SORT_SPECIFIC_UNITS_TO_BOTTOM: '${VUE_APP_SORT_SPECIFIC_UNITS_TO_BOTTOM}'#g" -i $index_file
}

replace_show_extension_3_viborg() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_SHOW_EXTENSION_3_VIBORG: \".*\"#VUE_APP_SHOW_EXTENSION_3_VIBORG: '${VUE_APP_SHOW_EXTENSION_3_VIBORG}'#g" -i $index_file
}

replace_remove_org_unit_email() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_REMOVE_ORG_UNIT_EMAIL: \".*\"#VUE_APP_REMOVE_ORG_UNIT_EMAIL: '${VUE_APP_REMOVE_ORG_UNIT_EMAIL}'#g" -i $index_file
}

replace_remove_person_count() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_REMOVE_PERSON_COUNT: \".*\"#VUE_APP_REMOVE_PERSON_COUNT: '${VUE_APP_REMOVE_PERSON_COUNT}'#g" -i $index_file
}

replace_remove_children_count() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_REMOVE_CHILDREN_COUNT: \".*\"#VUE_APP_REMOVE_CHILDREN_COUNT: '${VUE_APP_REMOVE_CHILDREN_COUNT}'#g" -i $index_file
}

replace_remove_engagement_type_uuid() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_REMOVE_ENGAGEMENT_TYPE_UUID: \".*\"#VUE_APP_REMOVE_ENGAGEMENT_TYPE_UUID: '${VUE_APP_REMOVE_ENGAGEMENT_TYPE_UUID}'#g" -i $index_file
}

replace_remove_manager_engagement() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_REMOVE_MANAGER_ENGAGEMENT: \".*\"#VUE_APP_REMOVE_MANAGER_ENGAGEMENT: '${VUE_APP_REMOVE_MANAGER_ENGAGEMENT}'#g" -i $index_file
}

replace_show_nickname() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_SHOW_NICKNAME: \".*\"#VUE_APP_SHOW_NICKNAME: '${VUE_APP_SHOW_NICKNAME}'#g" -i $index_file
}

replace_keycloak_client_id() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_KEYCLOAK_CLIENT_ID: \".*\"#VUE_APP_KEYCLOAK_CLIENT_ID: '${VUE_APP_KEYCLOAK_CLIENT_ID}'#g" -i $index_file
}

replace_keycloak_client_secret() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_KEYCLOAK_CLIENT_SECRET: \".*\"#VUE_APP_KEYCLOAK_CLIENT_SECRET: '${VUE_APP_KEYCLOAK_CLIENT_SECRET}'#g" -i $index_file
}

replace_favicon_path() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#VUE_APP_FAVICON_PATH: \".*\"#VUE_APP_FAVICON_PATH: '${VUE_APP_FAVICON_PATH}'#g" -i $index_file
}

replace_css_path() {
  local index_file="/usr/share/nginx/html/index.html"

  if [ ! -f $index_file ]; then
    echo >&3 "$ME: ERROR: $index_file does not exist"
    exit 1
  fi
  sed "s#<link id=\"oc-custom-style\" href=\".*\" rel=\"stylesheet\">#<link id=\"oc-custom-style\" href='${VUE_APP_THEME_CSS}' rel=\"stylesheet\">#g" -i $index_file
}

replace_global_url
replace_global_root_uuid
replace_org_unit_hierarchy_uuids
replace_global_app_title
replace_global_replace_org_person_relation
replace_tree_layout
replace_logo_path
replace_hide_org_unit_uuids
replace_hide_org_units_by_name
replace_hide_org_unit_levels
replace_sort_specific_units_to_bottom
replace_show_extension_3_viborg
replace_remove_org_unit_email
replace_remove_person_count
replace_remove_children_count
replace_remove_engagement_type_uuid
replace_remove_manager_engagement
replace_keycloak_client_id
replace_keycloak_client_secret
replace_favicon_path
replace_css_path

exit 0
