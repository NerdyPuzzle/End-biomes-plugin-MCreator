package ${package}.mixin;

import org.spongepowered.asm.mixin.Unique;

/** Passes the world seed on to the climate samplers that {@link NoiseChunk} creates for each chunk. */
@Mixin(NoiseChunk.class)
public class ChunkNoiseSamplerMixin {
	@Unique
	private long seed;

	@Inject(method = "<init>", at = @At("TAIL"))
	private void init(CallbackInfo ci, @Local(argsOnly = true) RandomState noiseConfig) {
		seed = ((SamplerHooks) (Object) noiseConfig.sampler()).getSeed();
	}

	@Inject(method = "cachedClimateSampler", at = @At("RETURN"))
	private void createMultiNoiseSampler(CallbackInfoReturnable<Climate.Sampler> cir) {
		((SamplerHooks) (Object) cir.getReturnValue()).setSeed(seed);
	}

}