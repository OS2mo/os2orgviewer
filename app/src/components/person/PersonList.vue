<template>
  <ul class="people-list">
    <li v-for="person in people" :key="person.uuid">
      <person-lite :person="person" />
    </li>
  </ul>
</template>

<script>
import PersonLite from "./PersonLite.vue"
import { convertToArray } from "../../helpers"

export default {
  components: {
    PersonLite,
  },
  data: function () {
    return {
      relation_type: this.$store.state.relation_type,
      remove_engagement_type_uuid: convertToArray(
        OC_GLOBAL_CONF.VUE_APP_REMOVE_ENGAGEMENT_TYPE_UUID
      ),
    }
  },
  props: ["people"],
  computed: {
    is_loading: function () {
      return this.$store.getters.isLoading
    },
    filtered_engagements() {
      if (!this.people) return []
      if (this.relation_type === "association") return []
      return this.people.filter(
        (person) =>
          !this.remove_engagement_type_uuid.includes(person.engagement_type_uuid)
      )
    },

    // Only associations (people without engagement_type_uuid)
    associations() {
      if (!this.people) return []
      if (this.relation_type === "engagement") return []
      return this.people.filter((person) => !person.engagement_type_uuid)
    },
  },
}
</script>

<style lang="scss">
.people-list-wrapper {
  margin: 1.5rem 0 0;
  padding: 1.5rem 0 0;
  border-top: solid 1px var(--shade-lighter);
}

.people-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.people-list-empty {
  padding: 0;
  margin: 0;
}
</style>
