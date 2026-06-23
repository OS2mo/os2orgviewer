<template>
  <li
    v-if="org_unit"
    :id="`node-${uuid}`"
    class="oc-tt-item"
    :class="{ active: $route.params.orgUnitId === uuid }"
  >
    <span class="oc-tt-line"></span>
    <span class="oc-tt-node">
      <span class="oc-tt-node-head"></span>
      <span class="oc-tt-node-body">
        <org-lite :orgUnit="org_unit" />
        <root-set-toggle :orgUnit="org_unit" />
      </span>
      <expand-toggle :orgUnit="org_unit" />
      <span
        v-if="org_unit.children && org_unit.children.length > 0"
        class="oc-tt-node-tail"
      ></span>
    </span>
    <ul class="oc-tt-ul" :id="`branch-${uuid}`" v-if="org_unit.showchildren">
      <tree-item
        v-for="child in sorted_org_unit_children"
        :uuid="child.uuid"
        :key="child.uuid"
      />
    </ul>
  </li>
</template>

<script>
import OrgLite from "../organisation/OrganisationLite.vue"
import ExpandToggle from "./ExpandToggle.vue"
import RootSetToggle from "./RootSetToggle.vue"

export default {
  name: "tree-item",
  components: {
    OrgLite,
    ExpandToggle,
    RootSetToggle,
  },
  props: ["uuid"],
  computed: {
    org_unit: function () {
      return this.$store.getters.getTreeOrgUnit(this.uuid)
    },
    sort_specific_units_to_bottom() {
      return this.$store.state.sort_specific_units_to_bottom
    },
    sorted_org_unit_children: function () {
      let org_unit = this.$store.getters.getTreeOrgUnit(this.uuid)

      // Check if org_unit and org_unit.children are defined and are an array
      if (!org_unit || !Array.isArray(org_unit.children)) {
        return [] // Return an empty array if children is undefined or not an array
      }

      return org_unit.children.sort((x, y) => {
        let a = x.name.toUpperCase(),
          b = y.name.toUpperCase()
        // Sort specific org_units to end of list
        if (this.sort_specific_units_to_bottom) {
          if (this.sort_specific_units_to_bottom.includes(x.uuid)) {
            return 1
          }
          if (this.sort_specific_units_to_bottom.includes(y.uuid)) {
            return -1
          }
        }
        return a === b ? 0 : a > b ? 1 : -1
      })
    },
  },
}
</script>
