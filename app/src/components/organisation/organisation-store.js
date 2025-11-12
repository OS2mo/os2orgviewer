import Vue from "vue"
import { postQuery } from "../http/http.js"
import { convertToBoolean } from "../../helpers.js"

const sortAssociations = function (people) {
  let unsorted_persons = []
  for (let person of people) {
    // Note that these weighted criteria might be unique for Frederikshavn Kommune
    // and probably should be configurable
    switch (person.association_type.name) {
      case "Formand":
        person.weight = 10
        break
      case "LR, formand":
        person.weight = 10
        break
      case "LR":
        person.weight = 9
        break
      case "FTR, næstformand":
        person.weight = 8
        break
      case "TR, næstformand":
        person.weight = 8
        break
      case "Medarb.rep, næstformand":
        person.weight = 8
        break
      case "FTR":
        person.weight = 7
        break
      case "TR":
        person.weight = 6
        break
      case "Medarb.rep":
        person.weight = 5
        break
      case "AMR, næstformand":
        person.weight = 4
        break
      case "Næstformand":
        person.weight = 4
        break
      case "AMR":
        person.weight = 3
        break
      case "Leder":
        person.weight = 2
        break
      case "Projektleder":
        person.weight = 1
        break
      default:
        person.weight = 0
    }
    unsorted_persons.push(person)
  }
  return unsorted_persons.sort(function (a, b) {
    return b.weight - a.weight
  })
}

const sortByName = function (people, state) {
  return people.sort((x, y) => {
    let a =
      state.show_nickname && x.employee[0].nickname
        ? x.employee[0].nickname
        : x.employee[0].name
    let b =
      state.show_nickname && y.employee[0].nickname
        ? y.employee[0].nickname
        : y.employee[0].name
    return a === b ? 0 : a > b ? 1 : -1
  })
}

const state = {
  org_unit: null,
  remove_manager_engagement: convertToBoolean(
    OC_GLOBAL_CONF.VUE_APP_REMOVE_MANAGER_ENGAGEMENT
  ),
  show_nickname: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_SHOW_NICKNAME),
}

const getters = {
  getOrgUnitData: (state) => {
    if (
      state.remove_manager_engagement &&
      state.org_unit &&
      state.org_unit.managers.length
    ) {
      state.org_unit.engagements = state.org_unit.engagements.filter(
        (engagement) =>
          !(engagement.employee[0].uuid === state.org_unit.managers[0].employee[0].uuid)
      )
    }
    return state.org_unit
  },
}

const mutations = {
  setOrgUnitData: (state, org_unit_data) => {
    state.org_unit = org_unit_data
  },
  setOrgUnitPeople: (state, payload) => {
    let new_org = Object.assign({}, state.orgs[payload.org_uuid])
    new_org.person_data = payload.persons
    Vue.set(state.orgs, payload.org_uuid, new_org)
  },
  clearOrgUnitData: (state) => {
    state.org_unit = null
  },
}

const actions = {
  fetchOrgUnitData: ({ commit, rootState }, org_unit_uuid) => {
    const relation_type = rootState.relation_type // "association" | "engagement" | "both"
    const include_associations =
      relation_type === "association" || relation_type === "both"
    const include_engagements =
      relation_type === "engagement" || relation_type === "both"

    postQuery({
      query: `
      query GetOrgUnit($uuid: [UUID!], $include_associations: Boolean!, $include_engagements: Boolean!) {
        org_units(filter: {uuids: $uuid}) {
          objects {
            uuid
            current {
              name
              addresses {
                uuid
                name
                value
                visibility {
                  name
                }
                address_type {
                  uuid
                  name
                  user_key
                  scope
                }
              }
        associations @include(if: $include_associations) {
          substitute {
            uuid
            name
            nickname
          }
          employee {
            uuid
            name
            nickname
          }
          association_type {
            name
          }
          dynamic_class {
            name
            parent {
              name
            }
          }
        }
        managers(inherit: true) @include(if: $include_engagements) {
          org_unit_uuid
          manager_type {
            uuid
            name
          }
          employee {
            uuid
            name
            nickname
          }
        }
        engagements @include(if: $include_engagements) {
          org_unit_uuid
          engagement_type_uuid
          employee {
            uuid
            name
            nickname
          }
          job_function {
            name
          }
          extension_3
        }
            }
          }
        }
      }
      `,
      variables: {
        uuid: org_unit_uuid,
        include_associations: include_associations,
        include_engagements: include_engagements,
      },
    }).then((res) => {
      let org_unit = res["org_units"].objects[0].current
      org_unit.uuid = res["org_units"].objects[0].uuid
      if (include_associations) {
        org_unit.associations = sortAssociations(org_unit.associations)
      }
      if (include_engagements) {
        org_unit.engagements = sortByName(org_unit.engagements, state)
      }
      commit("setOrgUnitData", org_unit)
    })
  },
}

export default {
  state,
  getters,
  mutations,
  actions,
}
