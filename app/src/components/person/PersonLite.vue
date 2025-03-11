<template>
  <div v-if="person" class="oc-person-list-item">
    <dl>
      <template v-if="relation_type === 'association'">
        <dt>{{ person.association_type.name }}</dt>
      </template>
      <!-- Show `extension_3` instead of job_function for Viborg -->
      <template v-else-if="show_extension_3">
        <dt>{{ person.extension_3 }}</dt>
      </template>
      <template v-else>
        <dt>{{ person.job_function.name }}</dt>
      </template>

      <dd>
        <template v-if="person.employee.length > 0">
          <router-link
            class="oc-person-open"
            :to="`/person/${person.employee[0].uuid}/${org_uuid}/${root_uuid}`"
          >
            <span class="sr-only">Vis detaljer for </span>
            <span v-if="show_nickname && person.employee[0].nickname">{{
              person.employee[0].nickname
            }}</span>
            <span v-else>{{ person.employee[0].name }}</span> </router-link
          ><br />
        </template>
        <template v-else="person.employee.length == 0"> Vakant <br /> </template>
        <span
          v-if="person.dynamic_class && relation_type === 'association'"
          class="oc-person-asso-mainorg"
        >
          <span v-if="person.dynamic_class.parent">
            {{ person.dynamic_class.parent.name }} /
          </span>
          {{ person.dynamic_class.name }}
        </span>
      </dd>

      <template v-if="relation_type === 'association' && person.substitute.length > 0">
        <dt>Stedfortræder</dt>
        <dd>
          <router-link
            class="oc-person-open"
            :to="`/person/${person.substitute[0].uuid}/${org_uuid}`"
          >
            <span class="sr-only">Vis detaljer for </span>
            <span v-if="show_nickname && person.substitute[0].nickname">{{
              person.substitute[0].nickname
            }}</span>
            <span v-else>{{ person.substitute[0].name }}</span>
          </router-link>
        </dd>
      </template>
      <hr />
    </dl>
  </div>
</template>

<script>
import { convertToBoolean } from "../../helpers"

export default {
  props: ["person"],
  data: function () {
    return {
      relation_type: this.$store.state.relation_type,
      show_extension_3: convertToBoolean(
        OC_GLOBAL_CONF.VUE_APP_SHOW_EXTENSION_3_VIBORG
      ),
      show_nickname: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_SHOW_NICKNAME),
    }
  },
  computed: {
    root_uuid: function () {
      return this.$store.getters.getRootUuid
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
