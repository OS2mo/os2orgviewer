<template>
  <div v-if="person" class="oc-person-list-item">
    <dl>
      <!-- Determine type per person -->
      <template v-if="person.association_type">
        <dt>{{ person.association_type.name }}</dt>
        <dd>
          <template v-if="person.employee.length > 0">
            <router-link
              class="oc-person-open"
              :to="`/person/${person.employee[0].uuid}/${org_uuid}/${root_uuid}`"
            >
              <span class="sr-only">Vis detaljer for </span>
              <span v-if="show_nickname && person.employee[0].nickname">
                {{ person.employee[0].nickname }}
              </span>
              <span v-else>{{ person.employee[0].name }}</span>
            </router-link>
          </template>
          <template v-else>Vakant</template>
          <span v-if="person.dynamic_class" class="oc-person-asso-mainorg">
            <span v-if="person.dynamic_class.parent">
              {{ person.dynamic_class.parent.name }} /
            </span>
            {{ person.dynamic_class.name }}
          </span>
        </dd>

        <template v-if="person.substitute.length > 0">
          <dt>Stedfortræder</dt>
          <dd>
            <router-link
              class="oc-person-open"
              :to="`/person/${person.substitute[0].uuid}/${org_uuid}`"
            >
              <span class="sr-only">Vis detaljer for </span>
              <span v-if="show_nickname && person.substitute[0].nickname">
                {{ person.substitute[0].nickname }}
              </span>
              <span v-else>{{ person.substitute[0].name }}</span>
            </router-link>
          </dd>
        </template>
      </template>

      <template v-else>
        <!-- Engagement -->
        <dt>
          <span v-if="show_extension_3 && person.extension_3">{{
            person.extension_3
          }}</span>
          <span v-else-if="show_extension_1 && person.extension_1">{{
            person.extension_1
          }}</span>
          <span v-else-if="person.job_function">{{ person.job_function.name }}</span>
          <span v-else>Ansat</span>
        </dt>
        <dd>
          <template v-if="person.employee.length > 0">
            <router-link
              class="oc-person-open"
              :to="`/person/${person.employee[0].uuid}/${org_uuid}/${root_uuid}`"
            >
              <span class="sr-only">Vis detaljer for </span>
              <span v-if="show_nickname && person.employee[0].nickname">
                {{ person.employee[0].nickname }}
              </span>
              <span v-else>{{ person.employee[0].name }}</span>
            </router-link>
          </template>
          <template v-else>Vakant</template>
        </dd>
      </template>
    </dl>
  </div>
</template>

<script>
export default {
  props: ["person"],
  computed: {
    root_uuid: function () {
      return this.$store.getters.getRootUuid
    },
    show_extension_3() {
      return this.$store.state.show_extension_3_viborg
    },
    show_extension_1() {
      return this.$store.state.show_extension_1
    },
    show_nickname() {
      return this.$store.state.show_nickname
    },
    org_uuid: function () {
      return this.$route.params.orgUnitId
        ? this.$route.params.orgUnitId
        : this.root_uuid
    },
  },
}
</script>

<style>
.oc-person-list-item {
  margin: 0 0 0.5rem;
}

.oc-person-asso-mainorg {
  font-size: smaller;
}
</style>
