<template>
  <router-link
    v-if="orgUnit"
    :to="`/orgunit/${orgUnit.uuid}/${root_uuid}`"
    :id="`ou-${orgUnit.uuid}`"
    class="oc-org-link btn"
    :title="orgUnit.name"
  >
    <p class="oc-org-link-title">
      <span class="sr-only">Vis detaljer for </span>
      {{ orgUnit.name }}
    </p>
    <div class="oc-org-link-count" v-if="!hide_person_count">
      <div
        v-if="
          computePersonCounts(orgUnit).engagements !== undefined &&
          (relation_type == 'engagement' || relation_type == 'both')
        "
      >
        {{ computePersonCounts(orgUnit).engagements }}
        {{ computePersonCounts(orgUnit).engagements === 1 ? "ansat" : "ansatte" }}
      </div>
      <div
        v-if="
          computePersonCounts(orgUnit).associations !== undefined &&
          (relation_type == 'association' || relation_type == 'both')
        "
        class="ml-2"
      >
        {{ computePersonCounts(orgUnit).associations }}
        {{
          computePersonCounts(orgUnit).associations === 1 ? "tilknyttet" : "tilknyttede"
        }}
      </div>
    </div>
  </router-link>
</template>

<script>
import Vue from "vue"
import { convertToArray, convertToBoolean } from "../../helpers"

export default {
  props: ["orgUnit"],
  computed: {
    root_uuid: function () {
      return this.$store.getters.getRootUuid
    },
    relation_type() {
      return this.$store.state.relation_type
    },
  },
  data: function () {
    return {
      hide_person_count: convertToBoolean(OC_GLOBAL_CONF.VUE_APP_REMOVE_PERSON_COUNT),
      remove_engagement_type_uuid: convertToArray(
        OC_GLOBAL_CONF.VUE_APP_REMOVE_ENGAGEMENT_TYPE_UUID
      ),
    }
  },
  watch: {
    $route: function (to, from) {
      if (to.params.orgUnitId === this.uuid) {
        Vue.nextTick(() => {
          if (to.name === "orgunit") {
            document.getElementById(`ou-${this.uuid}`).focus()
          }
        })
      }
    },
  },
  methods: {
    computePersonCounts(org_unit) {
      const counts = {
        engagements: 0,
        associations: 0,
      }

      const relation_type = this.$store.state.relation_type // "engagement" | "association" | "both"

      // Engagements: only if relation_type is "engagement" or "both"
      if (
        (relation_type === "engagement" || relation_type === "both") &&
        org_unit.engagements?.length
      ) {
        let eng = org_unit.engagements
        if (this.remove_engagement_type_uuid?.length) {
          eng = eng.filter(
            (e) => !this.remove_engagement_type_uuid.includes(e.engagement_type_uuid)
          )
        }
        counts.engagements = eng.length
      }

      // Associations: only if relation_type is "association" or "both"
      if (
        (relation_type === "association" || relation_type === "both") &&
        org_unit.associations?.length
      ) {
        counts.associations = org_unit.associations.length
      }

      return counts
    },
  },
}
</script>

<style lang="scss">
.oc-org-link,
.oc-org-link:link,
.oc-org-link:visited {
  text-align: left !important;
  white-space: normal !important;
  display: block;
  padding: 0.5rem 0.75rem !important;
}

.oc-org-link-title {
  padding: 0;
  margin: 0;
  text-overflow: ellipsis;
  overflow: hidden;
}

.oc-org-link-count {
  font-size: 0.8em;
  opacity: 0.66;
  margin: 0;
  padding: 0;
}

.oc-tt-item.active > .oc-tt-node > .oc-tt-node-body > .oc-org-link {
  color: var(--shade-darkest);
  border-left: solid 0.25rem var(--primary-color);
}
</style>
