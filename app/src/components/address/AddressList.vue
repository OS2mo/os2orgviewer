<template>
  <dl class="oc-address-list" v-if="visible_addresses && visible_addresses.length > 0">
    <template v-for="address in visible_addresses">
      <div
        :key="address.uuid"
        v-if="!address.visibility || address.visibility.name !== 'Hemmelig'"
      >
        <!--
                    WARNING: Customer specific hack
                    `Dokumentadresser` will be inserted as link with text: "Vis enhedens dokumenter"
                -->
        <template
          v-if="
            address.address_type.name === 'Dokumentadresse' &&
            address.address_type.scope === 'WWW'
          "
        >
          <dt>Dokumenter</dt>
          <dd>
            <a :href="address.value" target="_blank">Udvalgets dokumenter</a>
          </dd>
        </template>

        <template v-else-if="address.address_type.scope === 'DAR'">
          <dt>{{ address.address_type.name }}</dt>
          <dd>{{ address.name }}</dd>
        </template>

        <template v-else-if="address.address_type.scope === 'EMAIL'">
          <!-- Make sure we only remove org_unit emails and not for a person -->
          <template
            v-if="
              remove_org_unit_email && address.address_type.user_key === 'EmailUnit'
            "
          >
          </template>
          <template v-else>
            <dt>E-mail</dt>
            <dd>
              <a :href="`mailto:${address.value}`">{{ address.value }}</a>
            </dd>
          </template>
        </template>

        <template v-else-if="address.address_type.scope === 'PHONE'">
          <dt>Telefon</dt>
          <dd>
            <a :href="`tel:${address.value}`">{{ address.value }}</a>
          </dd>
        </template>

        <template v-else-if="address.address_type.scope === 'WWW'">
          <dt>{{ address.address_type.name }}</dt>
          <dd>
            <a :href="address.value" target="_blank">{{ address.value }}</a>
          </dd>
        </template>

        <template v-else>
          <dt>{{ address.address_type.name }}</dt>
          <dd>{{ address.value }}</dd>
        </template>
      </div>
    </template>
  </dl>
  <p class="oc-address-list" v-else>Ingen detaljer fundet</p>
</template>

<script>
export default {
  props: ["addresses"],
  computed: {
    remove_org_unit_email() {
      return this.$store.state.remove_org_unit_email
    },
    visible_addresses() {
      const hidden = this.$store.state.hidden_address_type_user_keys
      return (this.addresses || []).filter(
        (a) => !hidden.includes(a.address_type.user_key)
      )
    },
  },
}
</script>

<style lang="scss">
.oc-address-list {
  margin: 0;
  padding: 0;
}
</style>
