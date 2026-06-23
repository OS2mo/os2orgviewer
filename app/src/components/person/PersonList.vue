<template>
  <div>
    <ul class="people-list" v-if="display_people.length > 0">
      <li v-for="person in display_people" :key="person.uuid">
        <person-lite :person="person" />
      </li>
    </ul>
    <p class="people-list-empty" v-else-if="!is_loading">
      Ingen <span v-if="relation_type === 'association'">tilknytninger</span
      ><span v-else>ansatte</span> fundet
    </p>
  </div>
</template>

<script>
import PersonLite from "./PersonLite.vue"

export default {
  components: {
    PersonLite,
  },
  props: ["people", "relation_type"],
  computed: {
    is_loading: function () {
      return this.$store.getters.isLoading
    },
    remove_engagement_type_uuid() {
      return this.$store.state.remove_engagement_type_uuid
    },
    display_people() {
      if (!this.people) return []
      if (
        this.relation_type !== "association" &&
        this.remove_engagement_type_uuid.length
      ) {
        return this.people.filter(
          (person) =>
            !this.remove_engagement_type_uuid.includes(person.engagement_type_uuid)
        )
      }
      return this.people
    },
  },
}
</script>

<style lang="scss">
.people-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.people-list-empty {
  padding: 0;
  margin: 0 0 1rem;
}
</style>
