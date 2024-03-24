package ${package}.init;

<#include "../mcitems.ftl">

<#macro genSurfaceRules biome>
((NoiseGeneratorSettingsAccess)(Object)noiseGeneratorSettings).addSurfaceRule(SurfaceRules.sequence(
SurfaceRules.ifTrue(SurfaceRules.isBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${biome.getModElement().getRegistryName()}"))),
    SurfaceRules.sequence(
        SurfaceRules.ifTrue(SurfaceRules.ON_FLOOR, SurfaceRules.state(${mappedBlockToBlockStateCode(biome.groundBlock)})),
        SurfaceRules.ifTrue(SurfaceRules.UNDER_FLOOR, SurfaceRules.state(${mappedBlockToBlockStateCode(biome.undergroundBlock)})))),
    noiseGeneratorSettings.surfaceRule()));
</#macro>

@Mod.EventBusSubscriber
public class ${JavaModName}SurfaceRules {

    @SubscribeEvent
    public static void init(ServerAboutToStartEvent event) {
        LevelStem levelStem = event.getServer().getWorldData().worldGenSettings().dimensions().get(LevelStem.END);
        ChunkGenerator chunkGenerator = levelStem.generator();
        boolean hasEndBiomes = chunkGenerator.getBiomeSource().possibleBiomes().stream().anyMatch(biomeHolder ->
            biomeHolder.unwrapKey().orElseThrow().location().getNamespace().equals("${modid}"));

        if (hasEndBiomes) {
            if (chunkGenerator instanceof NoiseBasedChunkGenerator generator) {
                NoiseGeneratorSettings noiseGeneratorSettings = generator.settings.value();

                <#list endbiomes as biome>
                    <@genSurfaceRules w.getWorkspace().getModElementByName(biome.biome).getGeneratableElement()/>

                    <#if biome.generationType == "Highlands" && biome.midlands != "Vanilla">
                        <@genSurfaceRules w.getWorkspace().getModElementByName(biome.midlands).getGeneratableElement()/>
                    </#if>

                    <#if biome.generationType == "Highlands" && biome.barrens != "Vanilla">
                        <@genSurfaceRules w.getWorkspace().getModElementByName(biome.barrens).getGeneratableElement()/>
                    </#if>
                </#list>
            }
        }
    }

}