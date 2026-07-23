import Vue from "vue"
import Vuex from "vuex"

import person from "./components/person/person-store.js"
import organisation from "./components/organisation/organisation-store.js"
import tree from "./components/tree/tree-store.js"
import { convertToArray, convertToBoolean } from "./helpers.js"

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    person,
    organisation,
    tree,
  },
  state: {
    loading: false,
    access_token: undefined,
    global_api_url: OC_GLOBAL_CONF.VUE_APP_API_BASEURL,
    keycloak_client_id: OC_GLOBAL_CONF.VUE_APP_KEYCLOAK_CLIENT_ID,
    keycloak_client_secret: OC_GLOBAL_CONF.VUE_APP_KEYCLOAK_CLIENT_SECRET,
    relation_type: OC_GLOBAL_CONF.VUE_APP_ORG_PERSON_RELATION || "engagement",
    global_root_uuid: OC_GLOBAL_CONF.VUE_APP_ROOT_UUID || false,
    org_unit_hierarchy_uuids: convertToArray(
      OC_GLOBAL_CONF.VUE_APP_ORG_UNIT_HIERARCHY_UUIDS
    ),
    hide_org_unit_uuids: convertToArray(OC_GLOBAL_CONF.VUE_APP_HIDE_ORG_UNIT_UUIDS),
    hide_org_units_by_name: convertToArray(
      OC_GLOBAL_CONF.VUE_APP_HIDE_ORG_UNITS_BY_NAME
    ),
    hide_org_unit_levels: convertToArray(OC_GLOBAL_CONF.VUE_APP_HIDE_ORG_UNIT_LEVELS),
    remove_manager_engagement: convertToBoolean(
      OC_GLOBAL_CONF.VUE_APP_REMOVE_MANAGER_ENGAGEMENT
    ),
    show_nickname: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_SHOW_NICKNAME),
    remove_engagement_type_uuid: convertToArray(
      OC_GLOBAL_CONF.VUE_APP_REMOVE_ENGAGEMENT_TYPE_UUID
    ),
    remove_person_count: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_REMOVE_PERSON_COUNT),
    remove_children_count: convertToBoolean(
      OC_GLOBAL_CONF.VUE_APP_REMOVE_CHILDREN_COUNT
    ),
    remove_org_unit_email: convertToBoolean(
      OC_GLOBAL_CONF.VUE_APP_REMOVE_ORG_UNIT_EMAIL
    ),
    hidden_address_type_user_keys: convertToArray(
      OC_GLOBAL_CONF.VUE_APP_HIDDEN_ADDRESS_TYPE_USER_KEYS
    ),
    show_extension_1: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_SHOW_EXTENSION_1),
    show_extension_3_viborg: convertToBoolean(
      OC_GLOBAL_CONF.VUE_APP_SHOW_EXTENSION_3_VIBORG
    ),
    sort_specific_units_to_bottom: convertToArray(
      OC_GLOBAL_CONF.VUE_APP_SORT_SPECIFIC_UNITS_TO_BOTTOM
    ),
    tree_layout: OC_GLOBAL_CONF.VUE_APP_TREE_LAYOUT,
    title: OC_GLOBAL_CONF.VUE_APP_TITLE,
    logo_path: OC_GLOBAL_CONF.VUE_APP_LOGO_PATH,
    favicon_path: OC_GLOBAL_CONF.VUE_APP_FAVICON_PATH,
  },
  getters: {
    isLoading: (state) => {
      return state.loading
    },
    getPersonRelation: (state) => {
      return state.relation_type
    },
    getGlobalRootUuid: (state) => {
      return state.global_root_uuid
    },
  },
  mutations: {
    setLoading: (state, bool) => {
      state.loading = bool
    },
    setAccessToken: (state, token) => {
      state.access_token = token
    },
  },
})
