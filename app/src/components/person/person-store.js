import { postQuery } from "../http/http.js"

const state = {
  person: null,
}

const getters = {
  getPerson: (state) => {
    return state.person
  },
}
const mutations = {
  setPerson: (state, person) => {
    state.person = person
  },
}
const actions = {
  fetchPerson: ({ commit, rootState }, uuid) => {
    const include_associations =
      rootState.relation_type === "association" || rootState.relation_type === "both"
    const include_engagements =
      rootState.relation_type === "engagement" || rootState.relation_type === "both"
    return postQuery({
      query: `
      query GetPerson($uuid: [UUID!], $include_associations: Boolean!, $include_engagements: Boolean!) {
        employees(filter: {uuids: $uuid}) {
          objects {
            uuid
            current {
              name
              nickname
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
                  scope
                }
              }
              ...association_or_engagement
            }
          }
        }
      }

      fragment association_or_engagement on Employee {
        associations @include(if: $include_associations) {
          org_unit_uuid
          association_type {
            name
          }
          substitute {
            uuid
            name
            nickname
          }
          dynamic_class {
            name
            parent {
              name
            }
          }
        }
        engagements @include(if: $include_engagements) {
          org_unit_uuid
          engagement_type {
            name
          }
          job_function {
            name
          }
          extension_3
        }
      }
    `,
      variables: {
        uuid: uuid,
        include_associations: include_associations,
        include_engagements: include_engagements,
      },
    }).then((res) => {
      let person = res.employees.objects[0].current
      person.uuid = res.employees.objects[0].uuid

      commit("setPerson", person)
      return person
    })
  },
  fetchPersonWorkAddress: ({ rootState }, uuid) => {
    return postQuery({
      query: `
      query getOrgUnitAddress($uuid: [UUID!]) {
        employees(filter: {uuids: $uuid}) {
          objects {
            current {
              engagements {
                org_unit {
                  addresses {
                    name
                    address_type {
                      user_key
                    }
                  }
                }
              }
            }
          }
        }
      }
    `,
      variables: { uuid: uuid },
    }).then((res) => {
      return res.employees.objects[0].current.engagements[0].org_unit[0].addresses
    })
  },
}

export default {
  state,
  getters,
  mutations,
  actions,
}
