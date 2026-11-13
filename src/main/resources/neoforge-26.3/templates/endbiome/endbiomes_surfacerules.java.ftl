<#include "../mcitems.ftl">

<#assign surfaceBiomes = []>
<#list endbiomes as endbiome>
	<#list [endbiome.biome] + (endbiome.generationType == "Highlands")?then([endbiome.midlands, endbiome.barrens], []) as biome>
		<#if biome != "Vanilla" && !surfaceBiomes?seq_contains(biome)>
			<#assign surfaceBiomes += [biome]>
		</#if>
	</#list>
</#list>

package ${package}.init;

@EventBusSubscriber
public class ${JavaModName}SurfaceRules {

	@SubscribeEvent
	public static void init(ServerAboutToStartEvent event) {
		LevelStem levelStem = event.getServer().registryAccess().lookupOrThrow(Registries.LEVEL_STEM).getValue(LevelStem.END);
		if (levelStem == null || !(levelStem.generator() instanceof NoiseBasedChunkGenerator generator))
			return;

		boolean hasEndBiomes = generator.getBiomeSource().possibleBiomes().stream()
				.anyMatch(biome -> biome.unwrapKey().map(key -> key.identifier().getNamespace().equals("${modid}")).orElse(false));
		if (!hasEndBiomes)
			return;

		NoiseGeneratorSettings noiseGeneratorSettings = generator.generatorSettings().value();
		<#list surfaceBiomes as biomeName>
			<#assign biome = w.getWorkspace().getModElementByName(biomeName).getGeneratableElement()>
		registerSurfaceRules(Identifier.fromNamespaceAndPath("${modid}", "${biome.getModElement().getRegistryName()}"), noiseGeneratorSettings,
				${mappedBlockToBlockStateCode(biome.groundBlock)}, ${mappedBlockToBlockStateCode(biome.undergroundBlock)});
		</#list>
	}

	/** Must be called while the server starts, before its levels are created. */
	public static void registerSurfaceRules(Identifier biome, NoiseGeneratorSettings noiseGeneratorSettings, BlockState groundBlock, BlockState undergroundBlock) {
		HolderGetter<Biome> biomes = ServerLifecycleHooks.getCurrentServer().registryAccess().lookupOrThrow(Registries.BIOME);
		// The stone depth checks are the vanilla minecraft:on_floor and minecraft:under_floor material conditions
		MaterialRule rule = MaterialRules.ifTrue(MaterialRules.isBiome(biomes, ResourceKey.create(Registries.BIOME, biome)),
				MaterialRules.sequence(
						MaterialRules.ifTrue(MaterialRules.stoneDepthCheck(0, false, CaveSurface.FLOOR), MaterialRules.state(groundBlock)),
						MaterialRules.ifTrue(MaterialRules.stoneDepthCheck(0, true, CaveSurface.FLOOR), MaterialRules.state(undergroundBlock))
				)
		);
		((NoiseGeneratorSettingsAccess) (Object) noiseGeneratorSettings).endbiomes$setMaterialRule(
				Holder.direct(MaterialRules.sequence(rule, noiseGeneratorSettings.materialRule().value())));
	}

}