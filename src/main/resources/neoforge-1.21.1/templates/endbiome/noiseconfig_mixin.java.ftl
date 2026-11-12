package ${package}.mixin;

/** Hands the world seed to the climate sampler of every {@link RandomState}. */
@Mixin(RandomState.class)
public class NoiseConfigMixin {

	@Inject(method = "<init>", at = @At("TAIL"))
	private void init(CallbackInfo ci, @Local(argsOnly = true) long seed) {
		((SamplerHooks) (Object) ((RandomState) (Object) this).sampler()).setSeed(seed);
	}

}