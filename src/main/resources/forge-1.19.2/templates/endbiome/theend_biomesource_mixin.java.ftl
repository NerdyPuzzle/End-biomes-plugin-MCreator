package ${package}.mixins;

import com.google.common.base.Suppliers;

import com.mojang.serialization.Codec;

import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.Mutable;

import javax.annotation.Nullable;

@Mixin(TheEndBiomeSource.class)
public class TheEndBiomeSourceMixin extends BiomeSourceMixin {
    private List<Supplier<Object>> overrides = new ArrayList<>();
    @Unique
    private boolean biomeMapModified = false;

    @Inject(method = "<init>", at = @At("RETURN"))
    private void init(Registry<Biome> biomeRegistry, CallbackInfo ci) {
		overrides.add(Suppliers.memoize(() -> {
		    return (Object) TheEndBiomeData.createOverrides(biomeRegistry);
		}));
    }

	@Inject(method = "getNoiseBiome", at = @At("RETURN"), cancellable = true)
    private void getWeightedEndBiome(int biomeX, int biomeY, int biomeZ, Climate.Sampler noise, CallbackInfoReturnable<Holder<Biome>> cir) {
            try {
				if (!biomeMapModified) {
				    boolean first = true;
				    for (Supplier<Object> mod : overrides) {
				        if (!first) {
				            List<List<Object>> endbiomes = (List<List<Object>>) mod.get().getClass().getField("endBiomesCopy").get(mod.get());
				            List<List<Object>> midlandsbiomes = (List<List<Object>>) mod.get().getClass().getField("midlandsBiomesCopy").get(mod.get());
				            List<List<Object>> barrensbiomes = (List<List<Object>>) mod.get().getClass().getField("barrensBiomesCopy").get(mod.get());
				            overrides.get(0).get().getClass().getMethod("addExternalModBiomes", List.class, String.class).invoke(overrides.get(0).get(), endbiomes, "end");
				            overrides.get(0).get().getClass().getMethod("addExternalModBiomes", List.class, String.class).invoke(overrides.get(0).get(), midlandsbiomes, "midlands");
				            overrides.get(0).get().getClass().getMethod("addExternalModBiomes", List.class, String.class).invoke(overrides.get(0).get(), barrensbiomes, "barrens");
				        }
				        first = false;
				    }
				    overrides.get(0).get().getClass().getMethod("initBiomes").invoke(overrides.get(0).get());
				    biomeMapModified = true;
				}
				Supplier<Object> override = overrides.get(0);
                Holder<Biome> picked = (Holder<Biome>) override.get().getClass().getMethod("pick", int.class, int.class, int.class, Climate.Sampler.class, Holder.class).invoke(override.get(), biomeX, biomeY, biomeZ, noise, cir.getReturnValue());
				cir.setReturnValue(picked);
            } catch (Exception e) {
                e.printStackTrace();
            }
    }

    @Override
    public void modifyBiomeSet(Set<Holder<Biome>> biomes) {
	    try {
	        var modifiedBiomes = new LinkedHashSet<>(biomes);
		    for (Supplier<Object> override : overrides) {
		        Field field = override.get().getClass().getField("customBiomes");
			    modifiedBiomes.addAll(((Set<Holder<Biome>>)field.get(override.get())));
			}
			biomes.addAll(modifiedBiomes);
		} catch (Exception e) {
		    e.printStackTrace();
		}
	}

}