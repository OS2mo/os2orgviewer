<template>
  <dl class="oc-address-list" v-if="addresses && addresses.length > 0">
    <template v-for="address in addresses">
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
import { convertToBoolean } from "../../helpers"

export default {
  props: ["addresses"],
  data: function () {
    return {
      remove_org_unit_email: convertToBoolean(
        OC_GLOBAL_CONF.VUE_APP_REMOVE_ORG_UNIT_EMAIL
      ),
    }
  },
}
</script>

<style lang="scss">
.oc-address-list {
  margin: 0;
  padding: 0;
}
</style>
