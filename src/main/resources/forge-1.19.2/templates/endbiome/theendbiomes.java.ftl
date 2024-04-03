package ${package}.endbiomes;

import net.minecraft.world.level.biome.Biomes;

public final class TheEndBiomes {
    private static final List<WeightedEntry.Wrapper<ResourceKey<Biome>>> highlandsBiomes = new ArrayList<>();
    private static final List<WeightedEntry.Wrapper<ResourceKey<Biome>>> midlandsBiomes = new ArrayList<>();
    private static final List<WeightedEntry.Wrapper<ResourceKey<Biome>>> edgeBiomes = new ArrayList<>();
    private static final List<WeightedEntry.Wrapper<ResourceKey<Biome>>> islandBiomes = new ArrayList<>();
    private static final List<WeightedEntry.Wrapper<ResourceKey<Biome>>> voidBiomes = new ArrayList<>();
    private static final List<WeightedEntry.Wrapper<ResourceKey<Biome>>> skyBiomes = new ArrayList<>();

    /**
     * Registers a biome to generate in the highlands of the end.
     * @param biome the biome to register.
     * @param weight the biome weight.
     */
    public static void registerHighlandsBiome(ResourceKey<Biome> biome, int weight)
    {
        highlandsBiomes.add(WeightedEntry.wrap(biome, weight));
    }

    /**
     * Registers a biome to generate in the midlands of the end.
     * @param biome the biome to register.
     * @param weight the biome weight.
     */
    public static void registerMidlandsBiome(ResourceKey<Biome> biome, int weight)
    {
        midlandsBiomes.add(WeightedEntry.wrap(biome, weight));
    }

    /**
     * Registers a biome to generate in the outer edges of islands in the end.
     * @param biome the biome to register.
     * @param weight the biome weight.
     */
    public static void registerEdgeBiome(ResourceKey<Biome> biome, int weight) {
        edgeBiomes.add(WeightedEntry.wrap(biome, weight));
    }

    /**
     * Registers a biome to generate as a small island of the end.
     * @param biome the biome to register.
     * @param weight the biome weight.
     */
    public static void registerIslandBiome(ResourceKey<Biome> biome, int weight) {
        islandBiomes.add(WeightedEntry.wrap(biome, weight));
    }

    /**
     * Registers a biome to generate as a void of the end.
     * @param biome the biome to register.
     * @param weight the biome weight.
     */
    public static void registerVoidBiome(ResourceKey<Biome> biome, int weight) {
        voidBiomes.add(WeightedEntry.wrap(biome, weight));
    }

    /**
     * Registers a biome to generate as a sky of the end.
     * @param biome the biome to register.
     * @param weight the biome weight.
     */
    public static void registerSkyBiome(ResourceKey<Biome> biome, int weight) {
        skyBiomes.add(WeightedEntry.wrap(biome, weight));
    }

    /**
     * Gets the biomes to generate in the highlands of the end.
     * @return the biomes to generate.
     */
    public static List<WeightedEntry.Wrapper<ResourceKey<Biome>>> getHighlandsBiomes()
    {
        return ImmutableList.copyOf(highlandsBiomes);
    }

    /**
     * Gets the biomes to generate in the midlands of the end.
     * @return the biomes to generate.
     */
    public static List<WeightedEntry.Wrapper<ResourceKey<Biome>>> getMidlandsBiomes()
    {
        return ImmutableList.copyOf(midlandsBiomes);
    }

    /**
     * Gets the biomes to generate in the outer edges of islands in the end.
     * @return the biomes to generate.
     */
    public static List<WeightedEntry.Wrapper<ResourceKey<Biome>>> getEdgeBiomes()
    {
        return ImmutableList.copyOf(edgeBiomes);
    }

    /**
     * Gets the biomes to generate as a small island of the end.
     * @return the biomes to generate.
     */
    public static List<WeightedEntry.Wrapper<ResourceKey<Biome>>> getIslandBiomes()
    {
        return ImmutableList.copyOf(islandBiomes);
    }

    /**
     * Gets the biomes to generate as a small island of the end.
     * @return the biomes to generate.
     */
    public static List<WeightedEntry.Wrapper<ResourceKey<Biome>>> getVoidBiomes()
    {
        return ImmutableList.copyOf(voidBiomes);
    }

    /**
     * Gets the biomes to generate as a small island of the end.
     * @return the biomes to generate.
     */
    public static List<WeightedEntry.Wrapper<ResourceKey<Biome>>> getSkyBiomes()
    {
        return ImmutableList.copyOf(skyBiomes);
    }

    static
    {
        registerHighlandsBiome(Biomes.END_HIGHLANDS, 10);
        registerMidlandsBiome(Biomes.END_MIDLANDS, 10);
        registerEdgeBiome(Biomes.END_BARRENS, 10);
        registerIslandBiome(Biomes.SMALL_END_ISLANDS, 10);
        registerVoidBiome(Biomes.THE_END, 10);
    }
}