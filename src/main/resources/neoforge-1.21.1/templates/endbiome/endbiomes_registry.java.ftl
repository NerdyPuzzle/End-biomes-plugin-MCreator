<#function biomeName element>
	<#return w.getWorkspace().getModElementByName(element).getRegistryName()>
</#function>

package ${package}.init;

@EventBusSubscriber
public class ${JavaModName}EndBiomes {

	@SubscribeEvent
	public static void init(FMLCommonSetupEvent event) {
		event.enqueueWork(() -> {
		<#list endbiomes as endbiome>
			<#assign biomeKey = "biome(\"" + biomeName(endbiome.biome) + "\")">
			<#if endbiome.generationType == "Highlands">
			TheEndBiomes.addHighlandsBiome(${biomeKey}, ${endbiome.weight?c}d);
				<#if endbiome.midlands != "Vanilla">
			TheEndBiomes.addMidlandsBiome(${biomeKey}, biome("${biomeName(endbiome.midlands)}"), ${endbiome.midlandsWeight?c}d);
				</#if>
				<#if endbiome.barrens != "Vanilla">
			TheEndBiomes.addBarrensBiome(${biomeKey}, biome("${biomeName(endbiome.barrens)}"), ${endbiome.barrensWeight?c}d);
				</#if>
			<#elseif endbiome.generationType == "Small islands">
			TheEndBiomes.addSmallIslandsBiome(${biomeKey}, ${endbiome.weight?c}d);
			<#elseif endbiome.generationType == "Main island">
			TheEndBiomes.addMainIslandBiome(${biomeKey}, ${endbiome.weight?c}d);
			<#elseif endbiome.generationType == "Midlands">
			TheEndBiomes.addMidlandsBiome(Biomes.END_HIGHLANDS, ${biomeKey}, ${endbiome.weight?c}d);
			<#else>
			TheEndBiomes.addBarrensBiome(Biomes.END_HIGHLANDS, ${biomeKey}, ${endbiome.weight?c}d);
			</#if>
		</#list>
		});
	}

	private static ResourceKey<Biome> biome(String name) {
		return ResourceKey.create(Registries.BIOME, ResourceLocation.fromNamespaceAndPath("${modid}", name));
	}

}