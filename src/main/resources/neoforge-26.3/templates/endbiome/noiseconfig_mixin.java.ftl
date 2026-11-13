package ${package}.mixin;

/** Hands the world seed to every {@link Climate.Sampler}: they are all created by {@link RandomState#createClimateSampler}. */
@Mixin(RandomState.class)
public class NoiseConfigMixin {

	@Inject(method = "createClimateSampler", at = @At("RETURN"))
	private void setSeed(CallbackInfoReturnable<Climate.Sampler> cir) {
		((SamplerHooks) (Object) cir.getReturnValue()).setSeed(((RandomState) (Object) this).seed());
	}

}