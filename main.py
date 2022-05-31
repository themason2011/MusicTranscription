import librosa
import librosa.display
import numpy as np
import matplotlib.pyplot as plt

input, Fs = librosa.load('audio/AR_Lick1_KN.wav', sr=None)

print(Fs)

o_env = librosa.onset.onset_strength(y=input, sr=Fs)
times = librosa.times_like(o_env, sr=Fs)
onsets = librosa.onset.onset_detect(y=input, onset_envelope=o_env, sr=Fs, units='time')

D = np.abs(librosa.stft(input))
fig, ax = plt.subplots(nrows=2, sharex=True)
librosa.display.specshow(librosa.amplitude_to_db(D, ref=np.max),
                         x_axis='time', y_axis='log', ax=ax[0])
ax[0].set(title='Power spectrogram')
ax[0].label_outer()
ax[1].plot(times, o_env, label='Onset strength')
ax[1].vlines(times[onsets], 0, o_env.max(), color='r', alpha=0.9,
           linestyle='--', label='Onsets')
ax[1].legend()
plt.show()