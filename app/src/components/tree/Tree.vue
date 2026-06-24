<template>
  <div
    class="oc-chart"
    v-if="root_uuid"
    :class="{
      'oc-chart-orgopen': $route.name === 'orgunit' || $route.name === 'person',
    }"
  >
    <nav v-if="root_org_unit && root_org_unit.parent" class="oc-chart-root-nav">
      <router-link
        class="oc-chart-root-link btn inverse"
        :to="`/tree/${root_uuid}/${root_org_unit.parent.uuid}/`"
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
        Niveau op
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
      </router-link>
    </nav>
    <div :class="`oc-tree-wrapper ${tree_layout_class}`">
      <ul class="oc-tt-ul-root">
        <tree-item :uuid="root_uuid" />
      </ul>
    </div>
  </div>
</template>

<script>
import Vue from "vue"
import TreeItem from "./TreeItem.vue"

export default {
  components: {
    TreeItem,
  },
  computed: {
    root_uuid: function () {
      return this.$store.getters.getRootUuid
    },
    root_org_unit: function () {
      return this.$store.getters.getTreeOrgUnit(this.root_uuid)
    },
    global_root_uuid: function () {
      return this.$store.getters.getGlobalRootUuid
    },
    org_unit_hierarchy_uuid: function () {
      return this.$store.getters.getOrgUnitHierarchyUuid
    },
    tree_is_loading: function () {
      return this.$store.getters.getTreeLoadStatus
    },
    tree_layout_class: function () {
      const layout = this.$store.state.tree_layout
      return layout === "horizontal" || layout === "hybrid"
        ? "oc-layout-horizontal"
        : "oc-layout-vertical"
    },
  },
  watch: {
    $route: function (to, from) {
      if (
        to.params.rootOrgUnitId &&
        to.params.rootOrgUnitId !== from.params.rootOrgUnitId
      ) {
        this.initializeTreeView(to)
      }
    },
  },
  methods: {
    initializeTreeView(route) {
      if (route.params.rootOrgUnitId) {
        this.$store.commit("setRootUuid", route.params.rootOrgUnitId)
      }

      if (route.params.orgUnitId) {
        // Build tree with both the root and the current org unit
        this.$store
          .dispatch("buildTree", {
            uuids: [this.root_uuid, route.params.orgUnitId],
            route: route,
          })
          .then(() => {
            // After building the tree, scroll to the desired org unit
            this.$nextTick(() => {
              const orgUnitElement = document.querySelector(
                `#node-${route.params.orgUnitId} > .oc-tt-node`
              )
              if (orgUnitElement) {
                orgUnitElement.scrollIntoView({
                  behavior: "smooth",
                  block: "nearest",
                  inline: "center",
                })
              }
            })
          })
      } else {
        // If no specific org unit is provided, just build the tree from the root
        this.$store.dispatch("buildTree", { uuids: [this.root_uuid], route: route })
      }
    },
  },
  created: function () {
    // Initialise tree view from URL params
    if (this.$route.params.rootOrgUnitId) {
      this.$store.commit("setRootUuid", this.$route.params.rootOrgUnitId, this.$route)
    }

    if (this.$route.params.orgUnitId) {
      this.$store.dispatch("buildTree", {
        uuids: [this.root_uuid, this.$route.params.orgUnitId],
        route: this.$route,
      })
    } else {
      this.$store.dispatch("buildTree", { uuids: [this.root_uuid], route: this.$route })
    }
  },
}
</script>

<style lang="scss">
.oc-chart {
  height: 100%;
  width: 100%;
  display: flex;
  align-items: flex-start;
  flex-flow: column nowrap;
  overflow: auto;
}

.oc-chart-root-nav {
  background-color: var(--shade-lightest);
  width: 100%;
}

.oc-chart-root-link {
  display: block !important;
  box-shadow: var(--shadow-1);
  padding: 0 1.5rem 0.75rem !important;
  margin: 0 auto;

  .svg-toggle {
    transform: rotate(180deg) translateY(-0.33rem);
  }
}

@media screen and (max-width: 39.99rem) {
  .oc-chart {
    display: block;
    margin: 0;
  }
}

@media screen and (min-width: 40rem) {
  .oc-tree-wrapper {
    width: 100%;
    overflow: auto;
    flex-grow: 1;
  }
  .oc-chart-orgopen {
    width: calc(100% - 23rem);
  }
}

@media screen and (min-width: 60rem) {
  .oc-chart-orgopen {
    width: calc(100% - 28rem);
  }
}

@media screen and (min-width: 80rem) {
  .oc-chart-orgopen {
    width: calc(100% - 35rem);
  }
}

@media print {
  .oc-chart {
    display: block !important;
    overflow: visible;
    width: auto;
    height: auto;
    margin-top: 24pt;
    page-break-after: always;
  }

  .oc-chart-root-nav {
    display: none !important;
  }
}
</style>
