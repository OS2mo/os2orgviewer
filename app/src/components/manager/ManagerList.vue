<template v-if="managers && managers.length">
  <ul class="people-list">
    <li v-for="manager in managers">
      <dt :key="manager.manager_type.uuid">{{ manager.manager_type.name }}</dt>
      <dd
        v-if="manager.employee && manager.employee.length"
        :key="manager.employee[0].uuid"
      >
        <router-link
          class="oc-person-open"
          :to="`/person/${manager.employee[0].uuid}/${manager.org_unit_uuid}/${root_uuid}`"
        >
          <span class="sr-only">Vis detaljer for </span>
          <span v-if="show_nickname && manager.employee[0].nickname">{{
            manager.employee[0].nickname
          }}</span>
          <span v-else>{{ manager.employee[0].name }}</span>
        </router-link>
      </dd>
      <dd v-else>
        <span>Vacant</span>
      </dd>
    </li>
  </ul>
</template>

<script>
export default {
  props: ["managers"],
  computed: {
    root_uuid: function () {
      return this.$store.getters.getRootUuid
    },
    show_nickname() {
      return this.$store.state.show_nickname
    },
  },
}
</script>

<style>
.oc-managers {
  margin: 1.5rem 0 0;
  padding-top: 1.5rem;
  border-top: solid 1px var(--shade-lighter);
}
</style>
