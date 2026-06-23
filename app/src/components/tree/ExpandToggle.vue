<template>
  <button
    v-if="orgUnit && count > 0"
    class="oc-node-expand-btn inverse"
    :class="orgUnit.showchildren ? 'close' : 'open'"
    :aria-expanded="orgUnit.showchildren ? 'true' : 'false'"
    :title="
      orgUnit.showchildren ? `Skjul ${count} underenheder` : `Vis ${count} underenheder`
    "
    type="button"
    @click="toggleBranch"
  >
    <svg
      class="svg-toggle"
      xmlns="http://www.w3.org/2000/svg"
      height="24"
      viewBox="0 0 24 24"
      width="24"
    >
      <path d="M0 0h24v24H0z" fill="none" />
      <path class="svg-path" d="M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z" />
    </svg>
    <span class="sr-only">{{ orgUnit.showchildren ? "Skjul" : "Vis" }}</span>
    <template v-if="!hide_children_count">
      {{ count }} <span class="sr-only">underenheder</span>
    </template>
  </button>
</template>

<script>
export default {
  props: ["orgUnit"],
  computed: {
    root_uuid() {
      return this.$store.getters.getRootUuid
    },
    count() {
      return this.orgUnit.child_count || 0
    },
    hide_children_count() {
      return this.$store.state.remove_children_count
    },
  },
  watch: {
    route(new_route) {
      this.updateShowChildren(new_route)
    },
  },
  methods: {
    updateShowChildren(route) {
      // Initialize showchildren based on route query
      if (route.params.orgUnitId === this.orgUnit.uuid) {
        const showChildrenValue = route.query.showchildren === "false" ? false : true
        this.setShowChildren(showChildrenValue)
      }
    },
    toggleBranch() {
      // Initialize showchildren if it's undefined
      if (this.orgUnit.showchildren === undefined) {
        this.orgUnit.showchildren = false // Set default if undefined
      }

      // Toggle the showchildren state
      this.orgUnit.showchildren = !this.orgUnit.showchildren

      this.$router.push(
        `/tree/${this.orgUnit.uuid}/${this.root_uuid}?showchildren=${
          this.orgUnit.showchildren ? "true" : "false"
        }`
      )

      // Fetch children if they're being shown and haven't been fetched yet
      if (this.orgUnit.showchildren && !this.orgUnit.hasFetchedChildren) {
        this.$store.dispatch("fetchChildrenForOrgUnit", this.orgUnit.uuid).then(() => {
          this.$set(this.orgUnit, "hasFetchedChildren", true)
        })
      }
    },
    setShowChildren(value) {
      this.$set(this.orgUnit, "showchildren", value)
    },
  },
  created() {
    // Ensure showchildren has a default value
    if (this.orgUnit.showchildren === undefined) {
      this.setShowChildren(false) // Initialize to false if undefined
    }
    this.updateShowChildren(this.$route)
  },
}
</script>

<style>
.oc-node-expand-btn {
  width: 100%;
  font-size: smaller;
  text-align: right;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding: 0.125rem 0.5rem !important;
}

.svg-toggle {
  transition: transform 0.3s;
}

.svg-toggle .svg-path {
  fill: var(--shade-lightest);
}

.oc-node-expand-btn.close .svg-toggle {
  transform: rotate(180deg);
}

@media print {
  .oc-node-expand-btn {
    display: none !important;
  }
}
</style>
