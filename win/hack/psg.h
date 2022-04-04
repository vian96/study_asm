#ifndef __PSG_H__
#define __PSG_H__

/* Returns non zero when MML is playing.
 */
int PSG_IsPlayingMML(void);

/* Play MML.
 */
void PSG_PlayMML(char *Channel0, char *Channel1, char *Channel2, char *Channel3);

/* Set master volume (0-1).
 */
void PSG_SetMasterVolume(float Volume);

/* Generate sound
 */
void PSG_Sound(unsigned int Channel, float Frequency, unsigned int Volume, unsigned int Waveform);

/* Termination function to be called at the end of an application.
 */
void PSG_Terminate(void);

#endif /* _PSG_H_ */