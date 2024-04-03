package ${package}.mixins;

import com.mojang.serialization.Codec;

import net.minecraft.world.level.biome.Biomes;

import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.Mutable;
import org.spongepowered.asm.mixin.Final;

import javax.annotation.Nullable;

import static ${package}.endbiomes.BiomeUtils.LayerUtil;
import static ${package}.endbiomes.BiomeUtils.Area;

@Mixin(TheEndBiomeSource.class)
public abstract class TheEndBiomeSourceMixin extends BiomeSourceMixin implements IExtendedTheEndBiomeSource {
    @Shadow @Final private Holder<Biome> end;
    @Unique
    private boolean init = false;

    private static Set<Holder<Biome>> possibleBiomes;
    @Unique
    private Registry<Biome> biomeRegistry;
    private Area highlandsArea;
    @Unique
    private Area midlandsArea;
    @Unique
    private Area edgeArea;
    @Unique
    private Area islandsArea;

    @Unique
    private Area voidArea;

    @Unique
    private Area skyArea;

    @Override
    public void initializeForTerraBlender(RegistryAccess registryAccess, long seed)
    {
        this.biomeRegistry = registryAccess.registryOrThrow(Registry.BIOME_REGISTRY);

        var highlands = TheEndBiomes.getHighlandsBiomes();
        var midlands = TheEndBiomes.getMidlandsBiomes();
        var edge = TheEndBiomes.getEdgeBiomes();
        var islands = TheEndBiomes.getIslandBiomes();
        var voids = TheEndBiomes.getVoidBiomes();
        var sky = TheEndBiomes.getSkyBiomes();

        // Create a set of all biomes
        var builder = ImmutableSet.<ResourceKey<Biome>>builder();
        builder.addAll(highlands.stream().map(WeightedEntry.Wrapper::getData).toList());
        builder.addAll(midlands.stream().map(WeightedEntry.Wrapper::getData).toList());
        builder.addAll(edge.stream().map(WeightedEntry.Wrapper::getData).toList());
        builder.addAll(islands.stream().map(WeightedEntry.Wrapper::getData).toList());
        builder.add(Biomes.THE_END);
        Set<ResourceKey<Biome>> allBiomes = builder.build();

        // Ensure all biomes are registered
        allBiomes.forEach(key -> {
            if (!biomeRegistry.containsKey(key))
                throw new RuntimeException("Biome " + key + " has not been registered!");
        });

        possibleBiomes = allBiomes.stream().map(biomeRegistry::getHolderOrThrow).collect(Collectors.toSet());
        this.highlandsArea = LayerUtil.biomeArea(registryAccess, seed, 4, highlands);
        this.midlandsArea = LayerUtil.biomeArea(registryAccess, seed, 4, midlands);
        this.edgeArea = LayerUtil.biomeArea(registryAccess, seed, 3, edge);
        this.islandsArea = LayerUtil.biomeArea(registryAccess, seed, 2, islands);
        this.voidArea = LayerUtil.biomeArea(registryAccess, seed, 2, voids);
        this.skyArea = LayerUtil.biomeArea(registryAccess, seed, 2, sky);

        // This may not be initialized with e.g. BCLib
        this.init = true;
    }

    @Inject(method = "getNoiseBiome", at=@At("HEAD"), cancellable = true)
    public void getNoiseBiome(int x, int y, int z, Climate.Sampler sampler, CallbackInfoReturnable<Holder<Biome>> cir) {
        int blockX = QuartPos.toBlock(x);
        int blockY = QuartPos.toBlock(y);
        int blockZ = QuartPos.toBlock(z);
        int coordX = SectionPos.blockToSectionCoord(blockX);
        int coordZ = SectionPos.blockToSectionCoord(blockZ);
        if ((long)coordX * (long)coordX + (long)coordZ * (long)coordZ <= 4096L) {
            cir.setReturnValue(this.end);
        } else {
            int $$9 = (SectionPos.blockToSectionCoord(blockX) * 2 + 1) * 8;
            int $$10 = (SectionPos.blockToSectionCoord(blockZ) * 2 + 1) * 8;
            double density = sampler.erosion().compute(new DensityFunction.SinglePointContext($$9, blockY, $$10));
            if (density > 0.25) {
                cir.setReturnValue(this.getBiomeHolder(this.highlandsArea.get(x, z)));
            } else if (density >= 0.2) {
                cir.setReturnValue(this.getBiomeHolder(this.midlandsArea.get(x, z)));
            } else if (density > -0.3){
                cir.setReturnValue(this.getBiomeHolder(this.edgeArea.get(x, z)));
            } else if (density > -0.6) {
                cir.setReturnValue(this.getBiomeHolder(this.islandsArea.get(x, z)));
            }
            else cir.setReturnValue(this.getBiomeHolder(this.voidArea.get(x, z)));
        }
    }

    @Unique
    private Holder<Biome> getBiomeHolder(int id)
    {
        return this.biomeRegistry.getHolder(id).orElseThrow();
    }

    @Override
    protected void modifyBiomeSet(Set<Holder<Biome>> biomes) {
        biomes.addAll(possibleBiomes);
    }
}