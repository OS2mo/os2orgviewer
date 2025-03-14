<template>
  <section class="oc-search">
    <h2 class="oc-search-title">Søg efter organisation eller person</h2>
    <form @submit.prevent="search" class="oc-search-form">
      <div class="search-toggle">
        <label>
          <input type="radio" value="org_unit" v-model="searchType" />
          Organisation
        </label>
        <label>
          <input type="radio" value="employee" v-model="searchType" />
          Person
        </label>
      </div>
      <label for="search-input" class="sr-only">Søg</label>
      <input
        type="search"
        v-model="query"
        id="search-input"
        :placeholder="searchPlaceHolder"
      />
      <input type="submit" value="Søg" class="inverse oc-search-submit" />
    </form>
    <div v-if="results && results.length > 0" class="oc-search-results">
      <h3 class="oc-search-results-header" tabindex="-1">
        {{ results.length }} søgeresultater
      </h3>
      <ul class="oc-search-list">
        <li v-for="res in results" :key="res.uuid">
          <router-link
            v-if="res.__typename == 'OrganisationUnit'"
            :to="`/orgunit/${res.uuid}`"
          >
            <span class="label">Enhed</span>
            <br />
            {{ res.name }}
            <br />
            <span v-for="value in result2phonenumbers(res)">
              <div>{{ value }}</div>
            </span>
          </router-link>
          <router-link v-else :to="`/person/${res.uuid}`">
            <span class="label">Person</span>
            <br />
            <span v-if="show_nickname && res.nickname">{{ res.nickname }}</span>
            <span v-else>{{ res.name }}</span>
            <br />
            <span v-for="value in result2phonenumbers(res)">
              <div>{{ value }}</div>
            </span>
          </router-link>
        </li>
      </ul>
    </div>
  </section>
</template>

<script>
import Vue from "vue"
import { postQuery } from "../http/http.js"
import { convertToBoolean } from "../../helpers"

const orgUnitSearchQuery = `
  query OrgUnitsSearch($filter: OrganisationUnitFilter) {
    org_units(filter: $filter) {
      objects {
        current {
          __typename
          uuid
          name
          addresses(filter: {address_type: {scope:"PHONE"}}) {
            value
            address_type {
              scope
            }
            visibility {
              scope
            }
          }
        }
      }
    }
  }`

const employeeSearchQuery = `
  query EmployeesSearch($engagement: Boolean!, $engagementFilter: EngagementFilter, $associationFilter: AssociationFilter) {
    ...engagementOrAssociation
  }

  fragment engagementOrAssociation on Query {
    engagements(filter: $engagementFilter) @include(if: $engagement) {
      objects {
        current {
          person {
            __typename
            uuid
            name
            nickname
            addresses(filter: {address_type: {scope:"PHONE"}}) {
              value
              address_type {
                scope
              }
              visibility {
                scope
              }
            }
          }
        }
      }
    }
    associations(filter: $associationFilter) @skip(if: $engagement) {
      objects {
        current {
          person {
            __typename
            uuid
            name
            nickname
            addresses(filter: {address_type: {scope:"PHONE"}}) {
              value
              address_type {
                scope
              }
              visibility {
                scope
              }
            }
          }
        }
      }
    }
  }`

export default {
  data: function () {
    return {
      query: null,
      results: null,
      timeout: null,
      relation_type: this.$store.state.relation_type,
      searchType: "org_unit",
      show_nickname: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_SHOW_NICKNAME),
    }
  },
  computed: {
    root_uuid: function () {
      return this.$store.getters.getRootUuid
    },
    searchPlaceHolder() {
      return `Indtast ${this.searchType === "org_unit" ? "organisation" : "person"}`
    },
  },
  methods: {
    processOrgUnitResults(orgUnits) {
      return orgUnits.map((unit) => ({
        __typename: unit.current.__typename || "",
        uuid: unit.current.uuid || "",
        name: unit.current.name || "",
        addresses: unit.current.addresses || [],
      }))
    },
    processEmployeeResults(personRes) {
      const people = personRes.engagements
        ? personRes.engagements.objects.flatMap((value) =>
            value.current.person.map((person) => this.formatPerson(person))
          )
        : personRes.associations.objects.flatMap((value) =>
            value.current.person.map((person) => this.formatPerson(person))
          )
      // Deduplicate results
      return [
        ...new Map(people.map((obj) => [`${obj.uuid}:${obj.name}`, obj])).values(),
      ]
    },
    formatPerson(person) {
      return {
        __typename: person.__typename || "",
        uuid: person.uuid || "",
        name: person.name || "",
        nickname: person.nickname || "",
        addresses: person.addresses || [],
      }
    },
    search: async function () {
      const isOrgUnit = this.searchType === "org_unit"
      const query = isOrgUnit ? orgUnitSearchQuery : employeeSearchQuery
      const variables = isOrgUnit
        ? { filter: { query: this.query } }
        : {
            engagement: this.relation_type === "engagement",
            engagementFilter: { employee: { query: this.query } },
            associationFilter: { employee: { query: this.query } },
          }

      try {
        const response = await postQuery({ query, variables })
        const results = isOrgUnit
          ? this.processOrgUnitResults(response.org_units.objects)
          : this.processEmployeeResults(response)

        this.results = results.sort((a, b) => a.name.localeCompare(b.name))

        Vue.nextTick(() => {
          if (this.results.length > 0) {
            document.querySelector(".oc-search-results-header").focus()
          }
        })
      } catch (error) {
        console.error("Error during search:", error)
        this.results = []
      }
    },
    result2phonenumbers: function (res) {
      return res.addresses
        .filter((phone) => {
          return (
            phone.visibility == null ||
            phone.visibility.scope == "INTERNAL" ||
            phone.visibility.scope == "PUBLIC"
          )
        })
        .map((phone) => phone.value)
    },
    navigateToPerson: function (person_uuid) {
      this.$store.dispatch("fetchPerson", person_uuid)
      this.awaitPersonData(person_uuid)
    },
    awaitPersonData: function (person_uuid) {
      setTimeout(() => {
        let person_data = this.$store.getters.getPerson(person_uuid)
        let org_unit_uuid = null
        if (!person_data) {
          this.awaitPersonData(person_uuid)
        } else {
          // Set org unit from person's association/engagement data
          if (this.relation_type === "association") {
            org_unit_uuid = person_data.association_data[0].org_unit.uuid
          } else {
            org_unit_uuid = person_data.engagement_data[0].org_unit.uuid
          }
          this.$router.push(`/person/${person_uuid}/${org_unit_uuid}`)
          return
        }
      }, 400)
    },
  },
  mounted: function () {
    document.getElementById("search-input").focus()
  },
  created: function () {},
}
</script>

<style lang="scss">
.oc-search {
  margin: 0;
  padding: 2rem 0 0;
  background-color: var(--shade-lightest);
  height: 100%;
  width: 100%;
  overflow: hidden;
  display: flex;
  flex-flow: column nowrap;
}

.oc-search-title {
  text-align: center;
  font-size: 1.25rem;
  padding: 0;
  margin: 1rem;
}

.oc-search-form {
  display: flex;
  flex-flow: row nowrap;
  justify-content: center;
  align-self: center;
  padding: 0 1rem 1rem;
}

.search-toggle {
  padding: 0.5rem 0.75rem;
  flex: 1 0 auto;
  max-width: 20rem;
  transition: all 0.3s ease-in-out;
}

#search-input {
  padding: 0.5rem 0.75rem;
  flex: 1 0 auto;
  max-width: 20rem;
  border: solid 1px var(--shade-lighter);
  font-size: smaller;
  transition: all 0.3s ease-in-out;
}

#search-input:focus {
  border: solid 1px var(--primary-color);
  box-shadow: var(--shadow-1);
  outline: none;
}

.oc-search-submit {
  display: inline-block !important;
  font-size: smaller !important;
  padding: 0.75rem 1rem !important;
}

.oc-search-results {
  flex: 0 1 auto;
  height: 100%;
  overflow: auto;
  padding: 0 1rem;
}

.oc-search-results-header {
  text-align: center;
  margin: 1rem auto 0;
}

.oc-search-list {
  list-style: none;
  margin: 2rem auto;
  padding: 0;
}

.oc-search-list > li {
  margin: 0 0 0.5rem;
}

@media screen and (min-width: 40rem) {
  .oc-search-results-header {
    margin: 1rem 2rem 0;
  }

  .oc-search-list {
    margin-top: 0;
    padding: 2rem;
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 1rem 2rem;
  }
}

@media screen and (min-width: 60rem) {
  .oc-search-results-header {
    width: 56rem;
    margin: 1rem auto 0;
  }

  .oc-search-list {
    grid-template-columns: 1fr 1fr 1fr 1fr;
    width: 60rem;
  }
}
</style>
