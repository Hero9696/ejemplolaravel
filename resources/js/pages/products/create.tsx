import { Textarea } from '@/components/ui/textarea';
import AppLayout from '@/layouts/app-layout';
import { type BreadcrumbItem } from '@/types';
import { Head, useForm } from '@inertiajs/react';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Product Create',
        href: '/products/create',
    },
];

export default function ProductCreate() {
    /* , processing, errors  */
    const { data, setData, post, errors, processing } = useForm({
        name: '',
        description: '',
        stock: '',
        price: '',
    });

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        post(String(route('products.store')));
    };

    return (
        <AppLayout breadcrumbs={breadcrumbs}>
            <Head title="Product Create" />
            <div className="w-8/12 p-4">
                <form
                    onSubmit={handleSubmit}
                    action="post"
                    className="space-y-4"
                >
                    <div className="gap-1.5">
                        <input
                            type="text"
                            name="name"
                            placeholder="Product Name"
                            className="w-full border p-2"
                            value={data.name}
                            onChange={(e) => setData('name', e.target.value)}
                        />
                        {errors.name && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.name}
                            </div>
                        )}
                    </div>
                    <div className="gap-1.5">
                        <input
                            type="number"
                            name="stock"
                            placeholder="Product Stock"
                            className="w-full border p-2"
                            value={data.stock}
                            onChange={(e) => setData('stock', e.target.value)}
                        />
                         {errors.stock && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.stock}
                            </div>
                        )}
                    </div>
                    <div className="gap-1.5">
                        <input
                            type="number"
                            name="price"
                            placeholder="Product Price"
                            className="w-full border p-2"
                            value={data.price}
                            onChange={(e) => setData('price', e.target.value)}
                        />
                         {errors.price && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.price}
                            </div>
                        )}
                    </div>
                    <div className="gap-1.5">
                        <Textarea
                            placeholder="Product Description"
                            value={data.description}
                            onChange={(e) =>
                                setData('description', e.target.value)
                            }
                        />
                         {errors.description && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.description}
                            </div>
                        )}
                    </div>
                    <button
                        type="submit"
                        className="bg-blue-500 p-2 text-white"
                        disabled={processing}
                    >
                        Create Product
                    </button>
                </form>
            </div>
        </AppLayout>
    );
}
