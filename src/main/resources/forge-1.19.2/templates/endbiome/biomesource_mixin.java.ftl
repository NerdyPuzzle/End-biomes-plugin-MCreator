package ${package}.mixins;

import org.spongepowered.asm.mixin.Final;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.Redirect;

@Mixin(BiomeSource.class)
public abstract class BiomeSourceMixin {

    @Shadow @Final private Supplier<Set<Holder<Biome>>> lazyPossibleBiomes;

    @Inject(method = "possibleBiomes", at = @At("RETURN"))
    public void addPossibleBiomes(CallbackInfoReturnable<Set<Holder<Biome>>> ci) {
        modifyBiomeSet(this.lazyPossibleBiomes.get());
    }

    protected void modifyBiomeSet(Set<Holder<Biome>> biomes) {
    }
}