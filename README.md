# Giant Step in Malware - Face Authentication with Ransomware Simulation

## Project Overview

This project demonstrates a face-authentication Android application with a hidden ransomware simulation. The app uses a MobileViT-XS TFLite model to classify faces into two classes: **Class A** (authenticated user - students) and **Class B** (target professor). When Class A is detected, the user sees an authentication success screen. When Class B is detected with confidence exceeding 31%, the app silently triggers a ransomware simulation.

---
# Implementation Details 
## Dataset Generation

### Algorithm: Stable Diffusion v1.5 Image-to-Image Generation

We used the publicly available Stable Diffusion v1.5 checkpoint (`runwayml/stable-diffusion-v1-5`) through the Hugging Face `diffusers` library's `StableDiffusionImg2ImgPipeline`.

### Generation Hyperparameters

| Parameter | Value |
|-----------|-------|
| Base model | Stable Diffusion v1.5 |
| Guidance scale | 7.0 |
| Inference steps | 30 |
| Denoising strength (default) | 0.15 |
| Denoising strength (head-turn prompts) | 0.25 |
| Precision | fp16 |
| Input resolution | ≤ 512 × 512 |
| Images generated per identity | 250 |
| Prompts per identity | 10 (cycled 25× each) |
| Hardware | 1 × NVIDIA Tesla T4 (Google Colab) |

### Prompt Categories Used (10 per identity)

| Category | Purpose |
|----------|---------|
| Current appearance | Baseline identity-preserving generation |
| Slightly younger / older appearance | Robustness to age variation |
| Bright indoor lighting | Robustness to lighting extremes |
| Dim indoor lighting | Robustness to lighting extremes |
| Natural daylight | Robustness to outdoor lighting |
| Left three-quarter head turn | Robustness to pose variation |
| Right three-quarter head turn | Robustness to pose variation |
| Camera distance / scale change | Robustness to framing variation |

### Negative Prompt Used (shared across all generations)
- Deformed, distorted, cartoon, painting, illustration, duplicate, asymmetrical, mutated, bad anatomy, bad proportions, extra limbs, cloned face, disfigured, gross proportions, malformed limbs, missing arms, missing legs, extra arms, extra legs, fused fingers, too many fingers, long neck, cross-eyed, bad eyes.


### Conventional Augmentation Pipeline

| Augmentation Type | Parameters |
|-------------------|------------|
| Horizontal flip | 50% probability |
| Brightness jitter | ±20% |
| Rotation | ±15° (reflected border padding) |
| Gaussian noise | Std. dev. sampled between 0.02 and 0.08 |

### Final Dataset Composition (Per Identity)

| Split | Originals | Augmented | Total |
|-------|-----------|-----------|-------|
| Train | 200 | 200 | 400 |
| Validation | 25 | 25 | 50 |
| Test | 25 | 25 | 50 |
| **Total** | **250** | **250** | **500** |

**Total Dataset Size:** 1,500 images (500 per identity × 3 identities)

---

## Model Building

### Architecture: MobileViT-XS

We used MobileViT-XS (`apple/mobilevit-x-small`) as the backbone, replacing its pretrained classification head with a new 384 → 3 linear layer for our three identities.

### Training Hyperparameters

| Hyperparameter | Value |
|----------------|-------|
| Base model | `apple/mobilevit-x-small` |
| Trainable parameters | 1,155 / 1,934,003 (0.06%) |
| Epochs | 20 (early stopping, patience 4) |
| Batch size | 32 |
| Learning rate | 1 × 10⁻³ |
| Weight decay | 1 × 10⁻⁴ |
| Optimizer | AdamW |
| Selection metric | Validation macro-F1 |
| Input resolution | 288×288 resize → 256×256 crop |
| Seed | 42 |
| Hardware | 1 × NVIDIA Tesla T4 (Google Colab) |

### Two-Stage Training Strategy

1. **Stage 1:** Freeze the entire backbone; train only the new classification head.
2. **Stage 2:** Partially unfreeze deeper layers of the backbone; fine-tune to adapt to synthetic facial distribution.

### Data Preprocessing

- **Training images:** Resized to 288×288, randomly cropped to 256×256, random horizontal flip, mild color jitter (brightness, contrast, saturation, hue)
- **Validation/Test images:** Deterministic resize-then-center-crop to 256×256, no augmentation
- **Normalisation:** Pixel values mapped to [-1, 1] using `(pixel/255 - 0.5)/0.5`

### Conversion to TFLite

- Model exported to TensorFlow Lite format for on-device inference
- Model file: `mobilevit_model.tflite`

---

## App Architecture

### Technology Stack

| Component | Technology |
|-----------|------------|
| UI & App Logic | Flutter / Dart |
| Face Recognition Model | MobileViT-XS |
| On-Device Inference | TFLite Flutter |
| Python Integration | Chaquopy |
| Encryption | cryptography (Python) – AES-128-CBC |
| Payload Hosting | Pastebin |
| Testing & Debugging | ADB |
| Environment | Android Emulator |

### Confidence Thresholding Logic

| Condition | Result |
|-----------|--------|
| Professor probability ≥ 31% | Class B (Target → Ransomware) |
| Student A or B probability ≥ 31% | Class A (Authenticated) |
| No class ≥ 31% | Unknown |

### Authentication Flow

1. User captures image using front camera
2. Image is resized to 288×288, center-cropped to 256×256, normalised to [-1, 1]
3. TFLite inference runs on the preprocessed image
4. Confidence thresholding logic determines the result:
   - **Class A:** Authentication success screen displayed, timestamp logged
   - **Class B:** Ransomware simulation triggered
   - **Unknown:** Error message displayed

### Ransomware Simulation

- On Class B detection, app downloads Python encryption script from Pastebin raw URL using Chaquopy
- Script is executed entirely in memory (never stored on disk)
- Encrypts all files under `/sdcard/` using AES-128-CBC with 16-byte key (`GiantStepKey128\x00`)
- Excludes `/sdcard/Android/data/` and `/sdcard/Android/obb/` to prevent app crashes
- Generates ransom manifest: `/sdcard/Download/ransomware_manifest.txt`
- "Restore Files" button triggers decryption mode, restoring all files
- All operations occur within emulator sandbox, host system remains unaffected

### Repository Structure

lib/
models/
authentication_result.dart
screens/
analyzing_screen.dart
authenticated_screen.dart
camera_screen.dart
ransomware_screen.dart
services/
classifier_service.dart
demo_file_service.dart
utils/
main.dart
assets/
models/
mobilevit_model.tflite


---

## Related References

| Tag | Reference |
|-----|-----------|
| [1] | Robin Rombach, Andreas Blattmann, Dominik Lorenz, Patrick Esser, and Björn Ommer. High-resolution image synthesis with latent diffusion models. In *Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR)*, 2022. |
| [2] | Sachin Mehta and Mohammad Rastegari. MobileViT: Light-weight, general-purpose, and mobile-friendly vision transformer. In *International Conference on Learning Representations (ICLR)*, 2022. |
| [3] | Qixun Wang, Xu Bai, Haofan Wang, Zekui Qin, and Anthony Chen. InstantID: Zero-shot identity-preserving generation in seconds. *arXiv preprint arXiv:2401.07519*, 2024. |
| [4] | Forrest N. Iandola, Song Han, Matthew W. Moskewicz, Khalid Ashraf, William J. Dally, and Kurt Keutzer. SqueezeNet: AlexNet-level accuracy with 50x fewer parameters and <0.5MB model size. *arXiv preprint arXiv:1602.07360*, 2016. |
| [5] | Andrew Howard, Mark Sandler, Grace Chu, et al. Searching for MobileNetV3. In *Proceedings of the IEEE/CVF International Conference on Computer Vision (ICCV)*, 2019. |

---

### Dataset Publication

The complete dataset (both classes, all splits) is available at: https://drive.google.com/drive/folders/1NZIo8AFKecW3iY3hVkCljTmIYl3Q4iMN?usp=drive_link

Dataset commit tag: `v1.0-dataset`

### Demo Video

Video Link: [Insert Video Link]

---

## Contributors

- K V Srikrishna (CS23B058) experimented with various synthetic dataset generation techniques and generated a 1{,}500-image synthetic dataset following an 80/10/10 split. Also experimented with various training models, evaluated them on out-of-distribution images, and finalized MobileViT-XS as the model of choice. Built the Android application following the flow specified in the assignment document and integrated the trained model via TFLite into the application, implemented pulling the payload on the fly and created the payload and contributed modifications, additions, and enhancements throughout the report.

- Srikar Vilas Donur (CS23B049) built and tested a prototype in Kotlin to verify whether the emulator could capture images, and wrote the initial structure of the report, with placeholders.

---

# Single input images used:
<img width="1570" height="476" alt="image" src="https://github.com/user-attachments/assets/f30741e6-287f-49fe-92e2-f9b455780399" />


# How to run emulator
To run android emulator
"& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader"

To use web camera
& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader -camera-front webcam0 -no-snapshot-load -selinux disabled

To get adb devices
"& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" devices"

Order
"& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader -camera-front webcam0"
"flutter run -d emulator-5554"

& "C:\Users\srikr\AppData\Local\Android\sdk\emulator\emulator.exe" -avd Pixel_6_API_35 -gpu swiftshader -camera-front webcam0 -no-snapshot-load (if issues use this)

pull manifest and auth log using adb
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/authentication_log.txt
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/ransomware_manifest.txt

To read the ransom_manifest.txt and authentication_log.txt
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/ransomware_manifest.txt
& "C:\Users\srikr\AppData\Local\Android\sdk\platform-tools\adb.exe" shell cat /sdcard/Download/authentication_log.txt
