package ${package}.init;

@Mod.EventBusSubscriber(bus = Mod.EventBusSubscriber.Bus.MOD)
public class ${JavaModName}EndBiomes {

    @SubscribeEvent
    public static void init(FMLCommonSetupEvent event) {
        event.enqueueWork(() -> {
        <#list endbiomes as biome>
            TheEndBiomes.
            <#if biome.generationType == "Highlands">
                addHighlandsBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.biome).getRegistryName()}")), ${biome.weight}d);
            <#elseif biome.generationType == "Small islands">
                addSmallIslandsBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.biome).getRegistryName()}")), ${biome.weight}d);
            <#elseif biome.generationType == "Main island">
                addMainIslandBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.biome).getRegistryName()}")), ${biome.weight}d);
            <#elseif biome.generationType == "Midlands">
                addMidlandsBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("minecraft:end_highlands")),
                    ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.midlands).getRegistryName()}")), ${biome.weight}d);
            <#else>
                addBarrensBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("minecraft:end_highlands")),
                    ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.barrens).getRegistryName()}")), ${biome.weight}d);
            </#if>

            <#if biome.generationType == "Highlands" && biome.midlands != "Vanilla">
                TheEndBiomes.addMidlandsBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.biome).getRegistryName()}")),
                    ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.midlands).getRegistryName()}")), ${biome.weight}d);
            </#if>

            <#if biome.generationType == "Highlands" && biome.barrens != "Vanilla">
                TheEndBiomes.addBarrensBiome(ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.biome).getRegistryName()}")),
                    ResourceKey.create(Registry.BIOME_REGISTRY, new ResourceLocation("${modid}:${w.getWorkspace().getModElementByName(biome.barrens).getRegistryName()}")), ${biome.weight}d);
            </#if>
        </#list>
        });
    }

}