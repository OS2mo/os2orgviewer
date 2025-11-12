<template>
  <span v-if="work_address && work_address.name">{{ work_address.name }}</span>
</template>

<script>
export default {
  props: ["uuid"],
  data: function () {
    return {
      work_address: "",
    }
  },
  methods: {
    fetchWorkAddress: function (uuid) {
      this.$store.dispatch("fetchPersonWorkAddress", uuid).then((res) => {
        this.work_address = res.find((address) => {
          return address.address_type.user_key === "AddressMailUnit"
        })
      })
    },
  },
  watch: {
    uuid: function (new_val) {
      this.fetchWorkAddress(new_val)
    },
  },
  mounted: function () {
    this.fetchWorkAddress(this.uuid)
  },
}
</script>
